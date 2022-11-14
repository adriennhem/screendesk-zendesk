class ZendeskController < ApplicationController
    skip_before_action :verify_authenticity_token, except: [:connect]
    before_action :authenticate_user!, only: [:connect]
    before_action :allow_iframe, only: [:iframe, :ticket_editor]


    def connect
        query = {
            grant_type: "authorization_code",
            code: params[:code],
            client_id: 'zdg-screendesk',
            client_secret: Rails.application.credentials.dig(:zendesk, :api_secret),
            scope: "read write",
            redirect_uri: "#{Rails.configuration.variables[:base_url]}apps/zendesk/connect"
        }

        # Add params[:subdomain] in prod
        response = HTTParty.post("#{params[:state]}/oauth/tokens", query: query)
        if response.code == 200
            current_account.account_setting.update(
                zendesk_is_installed: true,
                zendesk_access_token: response['access_token'], 
                zendesk_token_type: response['token_type'],
                zendesk_subdomain: params[:state],
            )
            redirect_to "/integrations"
        else
            redirect_to "/integrations", notice: "Something went wrong. Please try again."
        end
    end

    def iframe
        @account_setting = AccountSetting.find_by(zendesk_subdomain: params[:origin])
        @origin = params[:origin]
    end

    def ticket_editor
        @account_setting = AccountSetting.find_by(zendesk_subdomain: params[:subdomain])
        @origin = params[:origin]
    end

    def get_details
        @account_setting = AccountSetting.find_by(zendesk_subdomain: params[:subdomain])
        if @account_setting.present? 
            account = @account_setting.account
            user = account.users.where(email: params[:user_email]).first
            if user.present?
                render json: {status: "success", account_key: account.key, user_key: user.key}
            else
                render json: {error: "Please ask an admin to add you to Screendesk"}, status: 401
            end
        else
            render json: {error: "Account not found"}, status: 404
        end 
    end

    def create_link
        user = User.find_by(key: params[:user_key])
        account = Account.find_by(key: params[:account_key])

        if user.present? && account.present?
            if params[:source] !=  "lsz"
                link = Link.create(
                    url: "#{Rails.configuration.variables[:base_url]}recordings/new?zid=#{params[:ticket_id]}&ak=#{params[:account_key]}&key=#{params[:user_key]}&src=#{params[:source]}",
                    user: user,
                    account: account,
                )
            else
                room = Room.create(
                    user: user,
                    account: account,
                )

                if room.save
                    link = Link.create(
                        url: "#{Rails.configuration.variables[:base_url]}rooms/#{room.uuid}",
                        user: user,
                        account: account,
                    )
                else
                    render json: {error: "Something went wrong. Please try again."}, status: 500
                end
            end
            if link.save
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
            recordings = account.recordings.where(customer_email: params[:customer_email], in_library: false).order(created_at: :desc).limit(3)
            if recordings.present?
                recordings.each do |recording|
                recording_response << {
                    title: recording.title,
                    duration: recording.formated_duration,
                    uuid: recording.uuid,
                    created_at: recording.created_at.strftime("%d %b %Y")
                }
                end
                render json: {status: "success", recordings: recording_response}
            else
                render json: {status: "success", recordings: []}
            end
        else
            render json: {error: "Something went wrong. Please try again."}, status: 500
        end
    end

    def allow_iframe
        response.headers.delete "X-Frame-Options"
    end
end
