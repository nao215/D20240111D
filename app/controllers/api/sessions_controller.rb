require_relative '../../services/session_service/validate_session'
require_relative '../../models/session'

class Api::SessionsController < ApplicationController
  before_action :authenticate_user!

  # GET /api/sessions/validate
  def validate
    token = params[:token]
    return render json: { message: "Invalid session token." }, status: :unprocessable_entity unless token

    result = SessionService::ValidateSession.new(current_user.id, token).call

    if result[:authenticated]
      render json: { status: 200, message: "Session is valid.", user_id: current_user.id }, status: :ok
    else
      case result[:message]
      when 'Invalid token'
        render json: { message: "Invalid session token." }, status: :unauthorized
      when 'Session has expired'
        render json: { message: "Session token has expired." }, status: :unauthorized
      else
        render json: { message: result[:message] }, status: :internal_server_error
      end
    end
  end

  private

  def authenticate_user!
    # Implement user authentication logic here
  end
end
