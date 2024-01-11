if @session_valid
  json.status 200
  json.message "Session is valid."
  json.user_id @user_id
elsif @error == "invalid_token"
  json.status 401
  json.message "Invalid session token."
elsif @error == "expired_token"
  json.status 401
  json.message "Session token has expired."
end
