# frozen_string_literal: true

module NoteService
  class Update
    def update_note(note_id:, title:, content:, user:)
      raise ActiveRecord::RecordInvalid, I18n.t('errors.messages.blank') if title.blank? || content.blank?

      note = user.notes.find(note_id)
      raise ActiveRecord::RecordNotFound unless note

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
