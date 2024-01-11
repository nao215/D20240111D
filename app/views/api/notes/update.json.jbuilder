class NotesController < ApplicationController
  # ... other controller actions ...

  def show
    @note = Note.find(params[:id])
    render json: Jbuilder.encode { |json|
      json.status 200
      json.note do
        json.id @note.id
        json.title @note.title
        json.content @note.content
        json.user_id @note.user_id # Added from new code
        json.created_at @note.created_at.iso8601
        json.updated_at @note.updated_at.iso8601
      end
    }
  end

  # ... other controller actions ...
end
