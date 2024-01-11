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

      if @title.blank? && @content.blank?
        return { valid: false, message: 'Title and content are missing' }
      elsif @title.blank?
        return { valid: false, message: 'Title is missing' }
      elsif @content.blank?
        return { valid: false, message: 'Content is missing' }
      end

      if @note_id
        note = user.notes.find_by(id: @note_id)
        return { success: false, message: 'Note not found' } unless note

        return { success: false, message: 'Title and content cannot be blank' } if @title.blank? || @content.blank?

        note.update(title: @title, content: @content, updated_at: Time.current)
        { success: true, note_id: note.id, message: 'Note updated successfully' }
      else
        note_id = @note_id || SecureRandom.uuid
        timestamp = Time.current

        note = Note.new(id: note_id, user_id: @user_id, title: @title, content: @content, created_at: timestamp, updated_at: timestamp)

        policy = NotePolicy.new(user, note) # Assuming NotePolicy is the correct policy class to use
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
