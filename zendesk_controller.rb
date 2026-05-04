# frozen_string_literal: true

class ZendeskController < ApplicationController
  skip_before_action :verify_authenticity_token, except: [:connect]
  before_action :zendesk_authenticate_user_with_sign_up!, only: [:connect]
  before_action :require_current_account_admin, only: %i[connect disconnect]
  before_action :log_integration_request!, except: %i[connect disconnect iframe ticket_editor form]
  before_action :allow_iframe, only: %i[iframe ticket_editor form]
  before_action :set_locale, only: [:form]

  def connect
    log_tag = '[INTEGRATION] [ZENDESK]'
    user_id = current_user&.id
    account_id = current_account&.id
    Rails.logger.info("#{log_tag} Connection initiated - user_id: #{user_id}, account_id: #{account_id}")

    query = {
      grant_type: "authorization_code",
      code: params[:code],
      client_id: "zdg-screendesk",
      client_secret: Rails.application.credentials.dig(:zendesk, :api_secret),
      scope: "read write",
      expires_in: 86400,
      refresh_token_expires_in: 7776000,
      redirect_uri:
        "#{Rails.configuration.variables[:base_url]}apps/zendesk/connect"
    }

    Rails.logger.debug(
      "#{log_tag} OAuth token request - subdomain: #{params[:state]}, " \
      'grant_type: authorization_code, client_id: zdg-screendesk'
    )

    response = HTTParty.post(
      "#{params[:state]}/oauth/tokens",
      query:,
      headers: ZendeskClient.marketplace_headers
    )

    if response.code == 200
      current_account.account_setting.update(
        zendesk_is_installed: true,
        zendesk_access_token: response["access_token"],
        zendesk_refresh_token: response["refresh_token"],
        zendesk_token_type: response["token_type"],
        zendesk_token_expires_at: response["expires_in"] ? Time.current + response["expires_in"].to_i.seconds : nil,
        zendesk_subdomain: params[:state]
      )

      AnalyticsService.track(user: current_user, account: current_account, event: "integration_connected", properties: { integration: "zendesk" })

      # Track onboarding checklist progress
      OnboardingTracker.track_integration_connected(user: current_user)

      Rails.logger.info("#{log_tag} Connection successful - user_id: #{user_id}, account_id: #{account_id}")
      redirect_to "/integrations"
    else
      sanitized_body = response.body.to_s.truncate(500)
      Rails.logger.error(
        "#{log_tag} Connection failed - user_id: #{user_id}, account_id: #{account_id}, " \
        "response_code: #{response.code}, response_body: #{sanitized_body}"
      )
      Sentry.capture_message(
        "#{log_tag} Connection failed",
        level: :error,
        extra: { user_id: user_id, account_id: account_id, response_code: response.code }
      )
      redirect_to "/integrations",
        notice: "Something went wrong. Please try again."
    end
  end

  def disconnect
    log_tag = '[INTEGRATION] [ZENDESK]'
    user_id = current_user&.id
    account_id = current_account&.id
    Rails.logger.info("#{log_tag} Disconnection initiated - user_id: #{user_id}, account_id: #{account_id}")

    if current_account.account_setting.update(
      zendesk_is_installed: false,
      zendesk_access_token: nil,
      zendesk_refresh_token: nil,
      zendesk_token_type: nil,
      zendesk_token_expires_at: nil,
      zendesk_subdomain: nil
    )
      Rails.logger.info("#{log_tag} Disconnection successful - user_id: #{user_id}, account_id: #{account_id}")
      redirect_to "/integrations", notice: "Zendesk has been successfully disconnected."
    else
      Rails.logger.error(
        "#{log_tag} Disconnection failed - user_id: #{user_id}, account_id: #{account_id}, " \
        "errors: #{current_account.account_setting.errors.full_messages}"
      )
      Sentry.capture_message(
        "#{log_tag} Disconnection failed",
        level: :error,
        extra: { user_id: user_id, account_id: account_id }
      )
      redirect_to "/integrations", alert: "Something went wrong. Please try again."
    end
  end

  def iframe
    @origin = params[:origin]
    @account_setting = AccountSetting.find_by(zendesk_subdomain: @origin)
  end

  def ticket_editor
    @origin = params[:origin]
    @account_setting = AccountSetting.find_by(zendesk_subdomain: @origin)
  end

  def background
    # Background app runs without user authentication
    # It only listens for notifications and displays toast messages
    render layout: false
  end

  def get_details
    @account_setting = AccountSetting.find_by(zendesk_subdomain: params[:zendesk][:subdomain])
    if @account_setting.present?
      account = @account_setting.account
      user = account.users.where(email: params[:user_email]).first

      if user.present?
        account_user = account.account_users.find_by(user:)

        if account_user&.watch_only?
          render json: {
            error: "Watch-only users cannot create recordings from Zendesk"
          }, status: 403
        else
          render json: {
            status: "success",
            account_key: account.key,
            user_key: user.key
          }
        end
      else
        render json: {
          error: "Please ask an admin to add you to Screendesk or you might have signed up to Screendesk with a different email than your Zendesk account"
        }, status: 401
      end
    else
      render json: {error: "Account not found"}, status: 404
    end
  end

  def create_link
    user = User.find_by(key: params[:user_key])
    account = Account.find_by(key: params[:account_key])

    if user.present? && account.present?
      if params[:source] != "lsz"
        link = Link.create(
          url: "#{Rails.configuration.variables[:base_url]}recordings/new?zid=#{params[:ticket_id]}&ak=#{params[:account_key]}&key=#{params[:user_key]}&src=#{params[:source]}",
          user:,
          account:
        )

        if link.save && account.account_setting.enable_zendesk_tags?
          begin
            require "zendesk_api"

            account.account_setting.ensure_fresh_zendesk_token!

            client = ZendeskAPI::Client.new do |config|
              url = "#{account.account_setting.zendesk_subdomain}/api/v2"
              config.url = url
              config.access_token = account.account_setting.zendesk_access_token
              config.retry = true

              # Add required Zendesk Marketplace headers
              config.client_options = {
                headers: ZendeskClient.marketplace_headers
              }
            end

            ticket = client.tickets.find(id: params[:ticket_id])
            ticket.tags << "screendesk-recording-requested"
            ticket.save!
          rescue ZendeskAPI::Error::RecordInvalid => e
            Rails.logger.error("Zendesk API Error: #{e.message}")
            # Continue execution without failing - the link is still created
          rescue ZendeskAPI::Error => e
            Rails.logger.error("Zendesk API Error: #{e.message}")
            # Continue execution without failing - the link is still created
          rescue AccountSetting::ZendeskTokenRefreshError => e
            Rails.logger.error("[INTEGRATION] [ZENDESK] Token refresh failed during create_link: #{e.message}")
            # Integration was just marked disconnected; the link is still created.
          end
        end
      else
        # Check if account has access to video_call feature
        unless account.has_feature?(:video_call)
          render json: {error: "Video call feature is not available on your current plan"}, status: 403
          return
        end

        room = Room.create(
          user:,
          account:,
          source: "zendesk",
          zendesk_conversation_id: params[:ticket_id]
        )

        if room.save
          link = Link.create(
            url: "#{Rails.configuration.variables[:base_url]}rooms/#{room.uuid}/join",
            user:,
            account:
          )
        else
          render json: {error: "Something went wrong. Please try again."}, status: 500
          return
        end
      end

      if link&.save
        # Track Zendesk activity for bi-monthly notifications
        user_setting = user.user_setting || user.create_user_setting
        user_setting.update(zendesk_last_activity_at: Time.current)

        render json: {status: "success", link: link.slug}
      else
        render json: {error: "Something went wrong. Please try again."}, status: 500
      end
    else
      render json: {error: "Something went wrong. Please try again."}, status: 500
    end
  end

  def get_recordings
    account = Account.find_by(key: params[:account_key])
    user = User.find_by(key: params[:user_key])
    recording_response = []

    if account.present? && user.present?
      recordings = if account.account_setting.integration_visible_recordings == "user"
        account
          .recordings
          .where(customer_email: params[:customer_email])
          .order(created_at: :desc)
          .limit(4)
      else
        account
          .recordings
          .where(customer_email: params[:customer_email])
          .where(zendesk_conversation_id: params[:ticket_id])
          .order(created_at: :desc)
          .limit(4)
      end
      if recordings.present?
        recordings.each do |recording|
          recording_response << {
            title: recording.title,
            duration: format_duration(recording.edited_duration || recording.duration),
            uuid: recording.uuid,
            source_type: recording.source_type,
            created_at: recording.created_at.strftime("%d/%m/%Y")
          }
        end
        render json: {status: "success", recordings: recording_response}
      else
        render json: {status: "success", recordings: []}
      end
    else
      render json: {
               error: "Something went wrong. Please try again."
             },
        status: 500
    end
  end

  def form
    @bgcolor = params[:bgcolor]
  end

  def search
    @account_setting = AccountSetting.find_by(zendesk_subdomain: params[:subdomain])
    if @account_setting.present?
      AnalyticsService.track(distinct_id: params[:email], account: @account_setting.account, event: "zendesk_search", properties: {
        query: params[:query],
        subdomain: params[:subdomain]
      })

      account = @account_setting.account
      recordings = if params[:query].start_with?("#")
        tag = params[:query].delete_prefix("#")
        account.recordings.where(reusable: true).tagged_with(tag).order(created_at: :desc)
      else
        account.recordings.where(reusable: true).search(params[:query]).limit(5)
      end

      if recordings.present?
        render json: {
          status: "success",
          recordings: recordings.map do |recording|
            {
              title: recording.title,
              duration: format_duration(recording.edited_duration || recording.duration),
              uuid: recording.uuid,
              created_at: recording.created_at.strftime("%b %d, %Y"),
              thumbnail_url: recording.custom_thumbnail.present? ? recording.custom_thumbnail.url : recording.thumbnail.url
            }
          end
        }
      else
        render json: {status: "success", recordings: []}
      end
    else
      render json: {error: "Account not found"}, status: 404
    end
  end

  def allow_iframe
    response.headers.delete "X-Frame-Options"
  end

  def set_locale
    I18n.locale =
      http_accept_language.compatible_language_from(I18n.available_locales)
  end

  private

  def log_integration_request!
    Rails.logger.info("ZENDESK: #{action_name} - #{request.method} #{request.url}")

    # Check for potential ad blocker indicators
    user_agent = request.user_agent.to_s.downcase
    return unless user_agent.include?("ublock") || user_agent.include?("adblock") || user_agent.include?("ghostery")

    Rails.logger.warn("POTENTIAL AD BLOCKER DETECTED: #{request.user_agent}")
  end
end
