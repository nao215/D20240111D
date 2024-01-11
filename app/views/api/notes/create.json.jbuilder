class NotesController < ApplicationController
  # ... other actions ...

  def create
    @note = Note.new(note_params)
    if @note.save
      render json: Jbuilder.encode { |json|
        json.status 201
        json.note do
          json.id @note.id
          json.status @note.status if @note.respond_to?(:status)
          json.user_id @note.user_id
          json.title @note.title
          json.content @note.content
          json.created_at @note.created_at.iso8601
          json.updated_at @note.updated_at.iso8601 if @note.updated_at.present?
        end
      }, status: :created
    else
      render json: Jbuilder.encode { |json|
        json.error @note.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def note_params
    params.require(:note).permit(:title, :content, :user_id)
  end

  # ... other private methods ...
end
