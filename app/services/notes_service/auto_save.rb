module NotesService
  class AutoSave < BaseService
    def initialize(user_id, title, content, id = nil)
      @user_id = user_id
      @title = title
      @content = content
      @id = id
    end

    def call
      user = User.find_by(id: @user_id)
      return { error: 'User not found' } unless user

      if @id
        note = user.notes.find_by(id: @id)
        return { error: 'Note not found' } unless note

        if @title.blank? || @content.blank?
          return { error: 'Title and content cannot be empty' }
        end

        note.title = @title
        note.content = @content
        note.updated_at = Time.current

        if note.save
          { note_id: note.id, message: 'Note updated successfully' }
        else
          { error: 'Failed to update note' }
        end
      else
        note = user.notes.create(title: @title, content: @content)
        { note_id: note.id, message: 'Note created successfully' }
      end
    end
  end
end
