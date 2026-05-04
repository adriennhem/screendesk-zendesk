# frozen_string_literal: true

# == Schema Information
#
# Table name: account_settings
#
#  id                                     :bigint           not null, primary key
#  audit_log_retention_days               :integer          default(365)
#  automation_github_access_token         :text
#  automation_github_is_connected         :boolean          default(FALSE)
#  automation_github_user_login           :string
#  automation_github_user_name            :string
#  automation_jira_access_token           :text
#  automation_jira_expires_at             :datetime
#  automation_jira_is_connected           :boolean          default(FALSE)
#  automation_jira_refresh_token          :text
#  automation_jira_site_name              :string
#  automation_jira_site_url               :string
#  automation_linear_access_token         :text
#  automation_linear_expires_at           :datetime
#  automation_linear_is_connected         :boolean          default(FALSE)
#  automation_linear_refresh_token        :text
#  automation_linear_team_name            :string
#  automation_slack_access_token          :text
#  automation_slack_is_connected          :boolean          default(FALSE)
#  automation_slack_team_name             :string
#  automation_trello_access_token         :text
#  automation_trello_board_name           :string
#  automation_trello_expires_at           :datetime
#  automation_trello_is_connected         :boolean          default(FALSE)
#  automation_trello_refresh_token        :text
#  cobrowsing_slug                        :string
#  console_logs_enabled                   :boolean          default(FALSE)
#  custom_color                           :string           default("#f43f5e")
#  default_capture_share_with             :integer          default("workspace_members"), not null
#  default_recording_share_with           :integer          default("anyone_with_link"), not null
#  disable_countdown                      :boolean
#  email_required                         :boolean          default(FALSE)
#  embed_slug                             :string
#  enable_audit_logs                      :boolean          default(FALSE)
#  enable_auto_data_deletion              :boolean          default(FALSE)
#  enable_blur                            :boolean          default(FALSE)
#  enable_console_logs                    :boolean          default(FALSE)
#  enable_freshdesk_tags                  :boolean          default(TRUE)
#  enable_intercom_tags                   :boolean          default(TRUE)
#  enable_labels                          :boolean          default(FALSE), not null
#  enable_live_recordings                 :boolean          default(TRUE)
#  enable_live_transcription              :boolean          default(FALSE)
#  enable_public_capture_sharing          :boolean          default(TRUE)
#  enable_recording_labels                :boolean          default(FALSE), not null
#  enable_zendesk_public_reply            :boolean          default(FALSE)
#  enable_zendesk_tags                    :boolean          default(TRUE)
#  freshdesk_api_key                      :string
#  freshdesk_chat_apikey                  :string
#  freshdesk_chat_domain                  :string
#  freshdesk_chat_is_installed            :boolean          default(FALSE)
#  freshdesk_domain                       :string
#  freshdesk_forward_email                :string
#  freshdesk_is_installed                 :boolean          default(FALSE)
#  freshdesk_slug                         :string           not null
#  freshservice_api_key                   :string
#  freshservice_domain                    :string
#  freshservice_is_installed              :boolean          default(FALSE)
#  guest_joins_camera_off                 :boolean          default(FALSE), not null
#  guest_joins_muted                      :boolean          default(FALSE), not null
#  helpscout_access_token                 :string
#  helpscout_agent_permissions            :integer          default(0), not null
#  helpscout_expiration_date              :integer
#  helpscout_expires_in                   :integer
#  helpscout_is_installed                 :boolean          default(FALSE)
#  helpscout_key_secret                   :string
#  helpscout_refresh_token                :string
#  helpscout_token_type                   :string
#  hide_chat                              :boolean          default(FALSE), not null
#  hide_participant_count                 :boolean          default(FALSE), not null
#  hide_people_panel                      :boolean          default(FALSE), not null
#  hide_pip_button                        :boolean          default(FALSE), not null
#  hide_settings_button                   :boolean          default(FALSE), not null
#  highlight_active_speaker               :boolean          default(TRUE), not null
#  hubspot_access_token                   :string
#  hubspot_expires_in                     :integer
#  hubspot_is_connected                   :boolean          default(FALSE)
#  hubspot_issued_at                      :datetime
#  hubspot_refresh_token                  :string
#  integration_visible_recordings         :integer          default("user")
#  intercom_access_token                  :string
#  intercom_forward_email                 :string
#  intercom_home_cta_text                 :string
#  intercom_is_installed                  :boolean          default(FALSE)
#  intercom_operator_cta_text             :string
#  intercom_token                         :string
#  intercom_token_type                    :string
#  jira_admin_email                       :string
#  jira_api_token                         :text
#  jira_attach_customer_portal_recordings :boolean          default(TRUE)
#  jira_domain                            :string
#  jira_enable_customer_portal            :boolean          default(FALSE)
#  jira_enable_ticket_updates             :boolean          default(TRUE)
#  jira_is_installed                      :boolean          default(FALSE)
#  jira_recording_attachment_type         :integer          default("private_note")
#  live_auto_deletion_period              :integer
#  live_custom_color                      :string           default("#404040")
#  live_recordings_start_trigger          :string           default("none")
#  precall_ceremony                       :boolean          default(FALSE), not null
#  precall_ceremony_can_skip              :boolean          default(FALSE), not null
#  precall_permission_help_link           :string
#  privacy_opt_in_enabled                 :boolean          default(FALSE)
#  privacy_opt_in_text                    :text
#  privacy_policy_link_text               :string
#  privacy_policy_url                     :string
#  privacy_translations                   :jsonb
#  received_auto_deletion_period          :integer
#  recorder_custom_color                  :string           default("#000000")
#  restrict_access_to_live_recordings     :boolean          default(FALSE)
#  restrict_access_to_received_recordings :boolean          default(FALSE)
#  sensitive_classes_ids                  :string
#  sent_auto_deletion_period              :integer
#  slack_access_token                     :string
#  slack_channel_name                     :string
#  slack_is_installed                     :boolean          default(FALSE)
#  slack_webhook_url                      :string
#  storage_location                       :string           default("america")
#  subgrid_labels                         :boolean          default(TRUE), not null
#  title_required                         :boolean          default(FALSE)
#  training_in_progress                   :boolean          default(FALSE)
#  video_call_consent_enabled             :boolean          default(FALSE), not null
#  video_call_consent_link_text           :string
#  video_call_consent_policy_url          :string
#  video_call_consent_text                :text
#  video_call_consent_translations        :jsonb
#  white_label_on                         :boolean          default(TRUE)
#  zendesk_access_token                   :string
#  zendesk_chat_request_recording_text    :string           default("Click here to record your screen: {{link}}"), not null
#  zendesk_form_slug                      :string           not null
#  zendesk_forward_email                  :string
#  zendesk_is_installed                   :boolean          default(FALSE)
#  zendesk_live_text                      :string           default("Join the live session here: {{link}}"), not null
#  zendesk_reply                          :text             default("Thanks for sending us a recording! We'll review it and get back to you as soon as possible.")
#  zendesk_request_recording_text         :string           default("{{Click here to record your screen}}"), not null
#  zendesk_subdomain                      :string
#  zendesk_token_type                     :string
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  account_id                             :integer          not null
#  automation_jira_cloud_id               :string
#  automation_linear_team_id              :string
#  automation_slack_bot_user_id           :string
#  automation_slack_team_id               :string
#  automation_trello_board_id             :string
#  intercom_workspace_id                  :string
#  jira_auth_id                           :string
#  slack_channel_id                       :string
#  slack_team_id                          :string
#
# Indexes
#
#  index_account_settings_on_automation_slack_team_id  (automation_slack_team_id)
#  index_account_settings_on_enable_labels             (enable_labels)
#  index_account_settings_on_enable_recording_labels   (enable_recording_labels)
#
class AccountSetting < ApplicationRecord
  class ZendeskTokenRefreshError < StandardError
    attr_reader :code, :body

    def initialize(code, body)
      @code = code
      @body = body
      super("Zendesk OAuth refresh failed (#{code})")
    end
  end

  enum integration_visible_recordings: {user: 0, ticket: 1}
  enum jira_recording_attachment_type: {private_note: 0, public_reply: 1}
  enum default_capture_share_with: {
    workspace_members: 0,
    anyone_with_link: 1
  }, _prefix: :capture_share
  enum default_recording_share_with: {
    workspace_members: 0,
    anyone_with_link: 1
  }, _prefix: :recording_share

  # Encrypt sensitive data
  encrypts :jira_api_token
  encrypts :intercom_access_token
  encrypts :intercom_token
  encrypts :helpscout_access_token
  encrypts :helpscout_refresh_token
  encrypts :helpscout_key_secret
  encrypts :zendesk_access_token
  encrypts :zendesk_refresh_token
  encrypts :hubspot_access_token
  encrypts :hubspot_refresh_token
  encrypts :slack_access_token
  encrypts :slack_webhook_url
  encrypts :freshservice_api_key
  encrypts :automation_linear_access_token
  encrypts :automation_linear_refresh_token
  encrypts :automation_slack_access_token
  encrypts :automation_github_access_token
  encrypts :automation_jira_access_token
  encrypts :automation_jira_refresh_token
  encrypts :automation_trello_access_token
  encrypts :automation_trello_refresh_token

  belongs_to :account
  has_one_attached :logo
  has_one_attached :room_logo
  has_one_attached :custom_thumbnail, service: :amazon_public

  # Broadcast changes in realtime with Hotwire
  # after_create_commit  -> { broadcast_prepend_later_to :account_settings, partial: "account_settings/index", locals: { account_setting: self } }
  # after_update_commit  -> { broadcast_replace_later_to self }
  # after_destroy_commit -> { broadcast_remove_to :account_settings, target: dom_id(self, :index) }

  validates_inclusion_of :received_auto_deletion_period, in: 1..730, allow_nil: true
  validates_inclusion_of :sent_auto_deletion_period, in: 1..730, allow_nil: true
  validates :storage_location, inclusion: {in: %w[america europe]}
  validates :logo, resizable_image: true
  validates :logo, content_type: ["image/png", "image/jpeg"]
  validates :logo, size: {less_than: 5.megabytes}
  validates :room_logo, resizable_image: true
  validates :room_logo, content_type: ["image/png", "image/jpeg"]
  validates :custom_thumbnail, resizable_image: true
  validates :custom_thumbnail, content_type: ["image/png", "image/jpeg"]
  validates :room_logo, size: {less_than: 5.megabytes}
  validates :zendesk_forward_email, email: true, allow_blank: true
  validates :intercom_forward_email, email: true, allow_blank: true
  validates :freshdesk_forward_email, email: true, allow_blank: true
  validates :jira_admin_email, email: true, allow_blank: true

  before_validation(on: :create) do
    self.helpscout_key_secret = generate_random_hex(10)
    self.embed_slug = generate_random_hex(3)
    self.zendesk_form_slug = generate_random_hex(3)
    self.freshdesk_slug = generate_random_hex(3)
  end

  after_update_commit :update_intercom_company

  def generate_random_hex(length)
    SecureRandom.hex(length)
  end

  # HubSpot token management
  def hubspot_token_expired?
    return true unless hubspot_is_connected? && hubspot_issued_at && hubspot_expires_in

    expires_at = hubspot_issued_at + hubspot_expires_in.seconds
    expires_at < Time.now
  end

  def hubspot_token_expires_soon?(threshold = 5.minutes)
    return true unless hubspot_is_connected? && hubspot_issued_at && hubspot_expires_in

    expires_at = hubspot_issued_at + hubspot_expires_in.seconds
    expires_at < threshold.from_now
  end

  # Linear automation token management
  def automation_linear_configured?
    automation_linear_access_token.present? &&
      automation_linear_team_id.present? &&
      automation_linear_is_connected
  end

  def automation_linear_token_expired?
    return true unless automation_linear_expires_at.present?

    automation_linear_expires_at < Time.current
  end

  def automation_linear_token_expires_soon?(threshold = 5.minutes)
    return true unless automation_linear_expires_at.present?

    automation_linear_expires_at < threshold.from_now
  end

  # Slack automation configuration check
  def automation_slack_configured?
    automation_slack_access_token.present? &&
      automation_slack_team_id.present? &&
      automation_slack_is_connected
  end

  # GitHub automation configuration check
  def automation_github_configured?
    automation_github_access_token.present? &&
      automation_github_is_connected
  end

  # Jira automation token management
  def automation_jira_configured?
    automation_jira_access_token.present? &&
      automation_jira_cloud_id.present? &&
      automation_jira_is_connected
  end

  def automation_jira_token_expired?
    return true unless automation_jira_expires_at.present?

    automation_jira_expires_at < Time.current
  end

  def automation_jira_token_expires_soon?(threshold = 5.minutes)
    return true unless automation_jira_expires_at.present?

    automation_jira_expires_at < threshold.from_now
  end

  # Trello automation token management
  # Note: Trello OAuth 1.0 tokens don't expire
  def automation_trello_configured?
    automation_trello_access_token.present? &&
      automation_trello_board_id.present? &&
      automation_trello_is_connected
  end

  # Zendesk OAuth token management
  # Legacy connections (created before refresh-token rollout) have no
  # zendesk_refresh_token / zendesk_token_expires_at and continue to work
  # under the soft cutover described in Zendesk's enhanced security guidelines.
  def zendesk_token_expired?
    return false unless zendesk_token_expires_at.present?

    zendesk_token_expires_at <= Time.current
  end

  def zendesk_token_expires_soon?(threshold = 5.minutes)
    return false unless zendesk_token_expires_at.present?

    zendesk_token_expires_at <= threshold.from_now
  end

  def zendesk_refreshable?
    zendesk_is_installed? &&
      zendesk_subdomain.present? &&
      zendesk_refresh_token.present?
  end

  # Refresh if the access token is expired/expiring and we have a refresh token.
  # No-op for legacy connections without a refresh token. Wrapped in with_lock
  # so concurrent jobs only trigger a single refresh (refresh-token rotation
  # invalidates the previous one). On unrecoverable failure (revoked / expired
  # refresh token), mark the integration disconnected and re-raise so callers
  # surface the error.
  def ensure_fresh_zendesk_token!
    return unless zendesk_refreshable?
    return unless zendesk_token_expires_soon?

    with_lock do
      # Re-check after acquiring the row lock — another process may have
      # already refreshed while we were waiting.
      refresh_zendesk_token! if zendesk_token_expires_soon?
    end
  rescue ZendeskTokenRefreshError => e
    Rails.logger.error(
      "[INTEGRATION] [ZENDESK] Marking integration disconnected after refresh failure - " \
      "account_id: #{account_id}, response_code: #{e.code}"
    )
    Sentry.capture_exception(
      e,
      level: :error,
      extra: { account_id: account_id, response_code: e.code }
    )
    mark_zendesk_disconnected!
    raise
  end

  # Clear all Zendesk credentials and mark the integration as not installed.
  # Used when the refresh token is revoked or expired and the customer needs
  # to re-authorize.
  def mark_zendesk_disconnected!
    update!(
      zendesk_is_installed: false,
      zendesk_access_token: nil,
      zendesk_refresh_token: nil,
      zendesk_token_type: nil,
      zendesk_token_expires_at: nil
    )
  end

  def refresh_zendesk_token!
    raise "Zendesk refresh token missing" if zendesk_refresh_token.blank?
    raise "Zendesk subdomain missing" if zendesk_subdomain.blank?

    response = HTTParty.post(
      "#{zendesk_subdomain}/oauth/tokens",
      query: {
        grant_type: "refresh_token",
        refresh_token: zendesk_refresh_token,
        client_id: "zdg-screendesk",
        client_secret: Rails.application.credentials.dig(:zendesk, :api_secret),
        scope: "read write",
        expires_in: 86400,
        refresh_token_expires_in: 7776000
      },
      headers: ZendeskClient.marketplace_headers
    )

    unless response.code == 200
      Rails.logger.error(
        "[INTEGRATION] [ZENDESK] Refresh failed - account_id: #{account_id}, " \
        "response_code: #{response.code}, body: #{response.body.to_s.truncate(500)}"
      )
      raise ZendeskTokenRefreshError.new(response.code, response.body.to_s)
    end

    update!(
      zendesk_access_token: response["access_token"],
      zendesk_refresh_token: response["refresh_token"] || zendesk_refresh_token,
      zendesk_token_type: response["token_type"],
      zendesk_token_expires_at: response["expires_in"] ? Time.current + response["expires_in"].to_i.seconds : nil
    )
  end

  def installed_integrations
    integrations = []
    integrations << "Intercom" if intercom_is_installed
    integrations << "Freshdesk" if freshdesk_is_installed
    integrations << "Freshservice" if freshservice_is_installed
    integrations << "HelpScout" if helpscout_is_installed
    integrations << "Jira" if jira_is_installed
    integrations << "Slack" if slack_is_installed
    integrations << "Zendesk" if zendesk_is_installed

    integrations.empty? ? "No integration installed" : integrations.join(", ")
  end

  def has_any_integration?
    intercom_is_installed ||
      freshdesk_is_installed ||
      freshservice_is_installed ||
      helpscout_is_installed ||
      jira_is_installed ||
      slack_is_installed ||
      zendesk_is_installed ||
      hubspot_is_connected
  end

  # Localized privacy opt-in accessors (mirrors RecorderFlowStep pattern)
  def localized_privacy_opt_in_text(locale = I18n.locale)
    return privacy_opt_in_text if locale.to_s == "en"
    privacy_translations&.dig(locale.to_s, "privacy_opt_in_text").presence || privacy_opt_in_text
  end

  def localized_privacy_policy_link_text(locale = I18n.locale)
    return privacy_policy_link_text if locale.to_s == "en"
    privacy_translations&.dig(locale.to_s, "privacy_policy_link_text").presence || privacy_policy_link_text
  end

  # Localized video call consent accessors
  def localized_video_call_consent_text(locale = I18n.locale)
    return video_call_consent_text if locale.to_s == "en"
    video_call_consent_translations&.dig(locale.to_s, "video_call_consent_text").presence || video_call_consent_text
  end

  def localized_video_call_consent_link_text(locale = I18n.locale)
    return video_call_consent_link_text if locale.to_s == "en"
    video_call_consent_translations&.dig(locale.to_s, "video_call_consent_link_text").presence || video_call_consent_link_text
  end

  # Auto-generated recording notice based on current settings
  def video_call_recording_notice
    return nil unless enable_live_recordings

    case live_recordings_start_trigger
    when "automatic", "automatic-2nd-participant"
      "This call will be recorded automatically."
    when "prompt"
      "This call may be recorded. The host will be prompted to start recording."
    else
      "This call may be recorded by the host."
    end
  end

  private

  def update_intercom_company
    IntercomService.update_company(self)
  end
end
