# rubocop:disable Style/ClassAndModuleChildren
module NotesService
  class Show
    attr_reader :note_id

    def initialize(note_id)
      @note_id = note_id
    end

    def execute
      note = Note.find_by(id: note_id)
      raise ActiveRecord::RecordNotFound, "Note not found" unless note

      note.as_json(only: [:id, :title, :content, :created_at, :updated_at])
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
