class ZendeskController < ApplicationController
  skip_before_action :verify_authenticity_token, except: [:connect]
  before_action :zendesk_authenticate_user_with_sign_up!, only: [:connect]
  before_action :allow_iframe, only: %i[iframe ticket_editor form background]
  before_action :set_locale, only: [:form]

  def connect
    query = {
      grant_type: "authorization_code",
      code: params[:code],
      client_id: "zdg-screendesk",
      client_secret: Rails.application.credentials.dig(:zendesk, :api_secret),
      scope: "read write",
      redirect_uri:
        "#{Rails.configuration.variables[:base_url]}apps/zendesk/connect"
    }

    response = HTTParty.post("#{params[:state]}/oauth/tokens", query: query)

    if response.code == 200
      current_account.account_setting.update(
        zendesk_is_installed: true,
        zendesk_access_token: response["access_token"],
        zendesk_token_type: response["token_type"],
        zendesk_subdomain: params[:state]
      )
      redirect_to "/integrations"
    else
      redirect_to "/integrations",
        notice: "Something went wrong. Please try again."
    end
  end

  def disconnect
    if current_account.account_setting.update(
      zendesk_is_installed: false,
      zendesk_access_token: nil,
      zendesk_token_type: nil,
      zendesk_subdomain: nil
    )
      redirect_to "/integrations", notice: "Zendesk has been successfully disconnected."
    else
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
    # Background location for toast notifications
    # No specific data needed as this runs silently
  end

  def get_details
    @account_setting = AccountSetting.find_by(zendesk_subdomain: params[:zendesk][:subdomain])
    if @account_setting.present?
      account = @account_setting.account
      user = account.users.where(email: params[:user_email]).first

      if user.present?
        account_user = account.account_users.find_by(user: user)

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
      render json: { error: "Account not found" }, status: 404
    end
  end

  def create_link
    user = User.find_by(key: params[:user_key])
    account = Account.find_by(key: params[:account_key])

    if user.present? && account.present?
      if params[:source] != "lsz"
        link = Link.create(
          url: "#{Rails.configuration.variables[:base_url]}recordings/new?zid=#{params[:ticket_id]}&ak=#{params[:account_key]}&key=#{params[:user_key]}&src=#{params[:source]}",
          user: user,
          account: account
        )

        if link.save
          if account.account_setting.enable_zendesk_tags?
            begin
              require "zendesk_api"

              client = ZendeskAPI::Client.new do |config|
                url = "#{account.account_setting.zendesk_subdomain}/api/v2"
                config.url = url
                config.access_token = account.account_setting.zendesk_access_token
                config.retry = true
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
            end
          end
        end
      else
        room = Room.create(
          user: user,
          account: account,
          source: "zendesk",
          zendesk_conversation_id: params[:ticket_id]
        )

        if room.save
          link = Link.create(
            url: "#{Rails.configuration.variables[:base_url]}rooms/#{room.uuid}/join",
            user: user,
            account: account
          )
        else
          render json: { error: "Something went wrong. Please try again." }, status: 500
          return
        end
      end

      if link&.save
        render json: { status: "success", link: link.slug }
      else
        render json: { error: "Something went wrong. Please try again." }, status: 500
      end
    else
      render json: { error: "Something went wrong. Please try again." }, status: 500
    end
  end

  def get_recordings
    account = Account.find_by(key: params[:account_key])
    user = User.find_by(key: params[:user_key])
    recording_response = []

    if account.present? && user.present?
      if account.account_setting.integration_visible_recordings == "user"
      recordings =
        account
          .recordings
          .where(customer_email: params[:customer_email])
          .order(created_at: :desc)
          .limit(4)
      else
        recordings =
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
      capture_posthog(params[:email], "zendesk_search", {
        query: params[:query],
        subdomain: params[:subdomain]
      }, {
        company: @account_setting.account.id
      })

      account = @account_setting.account
      recordings = if params[:query].start_with?('#')
                     tag = params[:query].delete_prefix('#')
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

  def capture_posthog(distinct_id, event, properties, groups)
    $posthog.capture({
       distinct_id: distinct_id,
       event: event,
       properties: properties,
       groups: groups
    })
  end
end
