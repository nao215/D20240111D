# frozen_string_literal: true

require 'active_record'
require '/app/models/note'
require '/app/policies/note_policy'

module NoteService
  class Update
    def update_note(note_id:, title:, content:, current_user:)
      raise 'Wrong format for note ID.' unless note_id.is_a?(Integer)
      raise 'The title is required.' if title.blank?
      raise 'The title cannot exceed 200 characters.' if title.length > 200
      raise 'The content is required.' if content.blank?

      raise 'User must be logged in' unless current_user

      note = Note.find_by(id: note_id, user_id: current_user.id)
      raise ActiveRecord::RecordNotFound unless note

      policy = NotePolicy.new(current_user, note)
      raise 'Not authorized to update this note' unless policy.update?

      note.title = title
      note.content = content
      note.updated_at = Time.current

      if note.save
        { status: 200, note: note.as_json.merge(user_id: current_user.id) }
      else
        raise ActiveRecord::RecordInvalid, note.errors.full_messages.to_sentence
      end
    rescue ActiveRecord::RecordNotFound
      raise ActiveRecord::RecordNotFound, I18n.t('errors.messages.not_found', entity: 'Note')
    end
  end
end
      note.title = title
      note.content = content
      note.updated_at = Time.current

      if note.save
        note
      else
        raise ActiveRecord::RecordInvalid, note.errors.full_messages.to_sentence
      end
    rescue ActiveRecord::RecordNotFound
      raise ActiveRecord::RecordNotFound, I18n.t('errors.messages.not_found', entity: 'Note')
    end
  end
end
