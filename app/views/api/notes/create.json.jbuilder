# Assuming this is the create action in the NotesController
def create
  @note = Note.new(note_params)
  if @note.save
    render json: Jbuilder.encode { |json|
      if @note.errors.any?
        json.error @note.errors.full_messages.first
      else
        json.status 201
        json.note do
          json.id @note.id
          json.title @note.title
          json.content @note.content
          json.user_id @note.user_id
          json.created_at @note.created_at.iso8601
          json.updated_at @note.updated_at.iso8601
        end
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
  # Assuming there's a method that whitelists the note parameters
  params.require(:note).permit(:title, :content, :user_id)
end
