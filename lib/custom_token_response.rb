module CustomTokenResponse
  def body
    additional_data = {
      'resource_owner' => @token&.resource_owner_type,
      'resource_id' => @token&.resource_owner_id
    }
    additional_data.merge!(refresh_token_expires_in: @token&.refresh_expires_in) if @token&.refresh_expires_in.present?

    # call original `#body` method and merge its result with the additional data hash
    super.merge(additional_data)
  end
end
