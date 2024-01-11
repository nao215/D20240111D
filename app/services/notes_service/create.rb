# rubocop:disable Style/ClassAndModuleChildren
module NotesService
  class Create < BaseService
    def call(user_id:, title:, content:, note_id: nil)
      user = User.find_by(id: user_id)
      return { error: 'User not found' } unless user

      if note_id
        note = user.notes.find_by(id: note_id)
        return { error: 'Note not found' } unless note

        if title.blank? || content.blank?
          return { error: 'Title and content cannot be empty' }
        end

        note.update(title: title, content: content, updated_at: Time.current)
        { note_id: note.id, message: 'Note updated successfully' }
      else
        return { error: 'Title and content cannot be empty' } if title.blank? || content.blank?

        note = user.notes.create(title: title, content: content)
        if note.persisted?
          { note_id: note.id, message: 'Note created successfully' }
        else
          { error: note.errors.full_messages.join(', ') }
        end
      end
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
