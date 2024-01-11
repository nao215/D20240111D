# frozen_string_literal: true

module NotesService
  class Create < BaseService
    def initialize(user_id:, title:, content:, note_id: nil)
      @user_id = user_id
      @title = title
      @content = content
      @note_id = note_id
    end

    def call
      user = User.find_by(id: @user_id)
      return { success: false, message: 'User not found' } unless user

      if @note_id
        note = Note.find_by(id: @note_id, user_id: @user_id)
        return { success: false, message: 'Note not found' } unless note

        return { success: false, message: 'Title and content cannot be blank' } if @title.blank? || @content.blank?

        note.update(title: @title, content: @content, updated_at: Time.current)
        { success: true, note_id: note.id, message: 'Note updated successfully' }
      else
        # Merged the new code's timestamp variable with the existing code's note_id generation
        note_id = @note_id || SecureRandom.uuid
        timestamp = Time.current

        # Merged the new code's Note.new without id with the existing code's Note.new with id
        note = Note.new(id: note_id, user_id: @user_id, title: @title, content: @content, created_at: timestamp, updated_at: timestamp)

        # Merged the policy check from both versions, preferring the new code's NotePolicy
        policy = NotePolicy.new(user, note)
        return { success: false, message: 'Not authorized to create note' } unless policy.create?

        if note.save
          { success: true, note_id: note.id, message: 'Note created successfully' }
        else
          { success: false, message: note.errors.full_messages.join(', ') }
        end
      end
    rescue StandardError => e
      { success: false, message: e.message }
    end

    private

    attr_reader :user_id, :title, :content, :note_id
  end
end
