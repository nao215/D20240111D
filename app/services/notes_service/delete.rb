# frozen_string_literal: true

module NotesService
  class Delete < BaseService
    def call(note_id:, user_id:)
      user = User.find(user_id)
      note = user.notes.find(note_id)

      authorize note, :destroy?

      if note.destroy
        { message: I18n.t('notes.delete.success', note_id: note_id) }
      else
        { error: note.errors.full_messages.to_sentence }
      end
    rescue Pundit::NotAuthorizedError
      { error: I18n.t('notes.delete.not_authorized') }
    rescue ActiveRecord::RecordNotFound
      { error: I18n.t('notes.delete.not_found') }
    end

    private

    def authorize(record, query)
      "#{record.class}Policy".constantize.new(user, record).public_send(query)
    end
  end
end
