
# rubocop:disable Style/ClassAndModuleChildren
require 'app/models/note.rb'
require 'app/policies/note_policy.rb'

class NoteService::Delete < BaseService
  def execute(note_id:, user:)
    # Authenticate the request
    raise 'User must be logged in' unless user.present?

    begin
      # Retrieve the note
      note = Note.find_by!(id: note_id, user_id: user.id)
      
      # Authorization check
      raise 'Not authorized to delete this note' unless NotePolicy.new(user, note).destroy?
      
      # Delete the note
      note.destroy
      { message: 'Note has been successfully deleted.' }
    rescue ActiveRecord::RecordNotFound => e
      { error: 'Note not found or not owned by the user.' }
    rescue => e
      { error: e.message }
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
