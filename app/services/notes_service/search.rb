# frozen_string_literal: true

module NotesService
  class Search
    def initialize(user_id:, search_query:)
      @user_id = user_id
      @search_query = search_query
    end

    def execute
      notes = Note.where(user_id: @user_id)
                   .where('title LIKE :query OR content LIKE :query', query: "%#{@search_query}%")
                   .order(Arel.sql("CASE WHEN title LIKE '%#{@search_query}%' THEN 1 ELSE 2 END, updated_at DESC"))

      formatted_notes = notes.map do |note|
        {
          id: note.id,
          title: note.title,
          content_preview: note.content.truncate(100),
          updated_at: note.updated_at
        }
      end

      formatted_notes
    end
  end
end
