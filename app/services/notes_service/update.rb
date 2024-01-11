# frozen_string_literal: true

module NotesService
  class Update < BaseService
    def initialize(note_id, user_id, title, content)
      @note_id = note_id
      @user_id = user_id
      @title = title
      @content = content
    end

    def call
      note = Note.find_by(id: @note_id, user_id: @user_id)
      raise ActiveRecord::RecordNotFound, 'Note not found' unless note

      authorize_user_for_note!(note)

      validate_presence_of_title_and_content!

      note.update!(title: @title, content: @content, updated_at: Time.current)

      { note_id: note.id, message: 'Note updated successfully' }
    rescue ActiveRecord::RecordInvalid => e
      { error: e.message }
    rescue ActiveRecord::RecordNotFound => e
      { error: e.message }
    end

    private

    def authorize_user_for_note!(note)
      policy = NotePolicy.new(@user_id, note)
      raise ActiveRecord::RecordNotFound, 'Not authorized to update note' unless policy.update?
    end

    def validate_presence_of_title_and_content!
      raise ActiveRecord::RecordInvalid, 'Title and content cannot be blank' if @title.blank? || @content.blank?
    end
  end
end
