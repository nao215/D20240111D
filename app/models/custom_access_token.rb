class CustomAccessToken < Doorkeeper::AccessToken
  before_create :set_expiration_time, if: :use_refresh_token?
  before_create :check_revoke_access_token

  def generate_refresh_token
    return super if previous_refresh_token.blank?

    @raw_refresh_token = previous_refresh_token
    secret_strategy.store_secret(self, :refresh_token, @raw_refresh_token)
  end

  def use_refresh_token?
    previous_refresh_token.blank?
  end

  def check_revoke_access_token
    return nil if old_refresh_token.blank? || old_refresh_token.refresh_expires_in.blank?

    time = old_refresh_token.created_at + old_refresh_token.refresh_expires_in.seconds
    expires = time - Time.now.utc
    expires_sec = expires.seconds.round(0)
    expires_sec.positive? ? false : custom_revoke_tokens
  end

  def custom_revoke_tokens
    old_refresh_token&.revoke
    self.class.where(previous_refresh_token: previous_refresh_token).map(&:revoke)
    self.revoked_at = Time.now.utc
  end

  private

  def set_expiration_time
    # configure refresh token expiration in future
    self.refresh_expires_in = Devise.remember_for
  end
end
