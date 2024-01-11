# frozen_string_literal: true

# This module encapsulates all the services related to notes.
module NotesService
  class Update < BaseService
    def initialize(note_id, user_id, title, content)
      @note_id = note_id
      @user_id = user_id
      @title = title
      @content = content
    end

    def call
      # The new code adds a user_id check to the note lookup, which is more secure.
      note = Note.find_by(id: @note_id, user_id: @user_id)
      raise ActiveRecord::RecordNotFound, 'Note not found' unless note

      # Ensures that the user has permission to update the note.
      authorize_user_for_note!(note)

      validate_presence_of_title_and_content!

      # The new code uses Time.current which is equivalent to Time.zone.now but is preferred for readability.
      note.update!(title: @title, content: @content, updated_at: Time.current)

      { note_id: note.id, message: 'Note updated successfully' }
    rescue ActiveRecord::RecordInvalid => e
      { error: e.message }
    # Handles the case where the note is not found or the user is not authorized.
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
