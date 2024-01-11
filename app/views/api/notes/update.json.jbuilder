class NotesController < ApplicationController
  # ... other controller actions ...

  def show
    @note = Note.find(params[:id])
    @error_message = nil # Assuming error_message is set somewhere in the code, if applicable

    render json: Jbuilder.encode { |json|
      json.status 200
      json.note do
        json.id @note.id
        json.user_id @note.user_id
        json.title @note.title
        json.content @note.content
        json.created_at @note.created_at.iso8601
        json.updated_at @note.updated_at.iso8601
      end

      if @error_message.present?
        json.status 422
        json.error @error_message
      end
    }
  end

  # ... other controller actions ...
end
