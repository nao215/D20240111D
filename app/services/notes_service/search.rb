
# frozen_string_literal: true

module NotesService
  class Search
    def initialize(user_id:, search_query:, page: 1, per_page: 10)
      @user_id = user_id
      @search_query = search_query
      @page = page
      @per_page = per_page
    end

    def paginate_notes(notes)
      notes.paginate(page: @page, per_page: @per_page)
    end

    def execute
      notes = paginate_notes(
        Note.where(user_id: @user_id)
            .where('title LIKE :query OR content LIKE :query', query: "%#{@search_query}%")
            .order(Arel.sql("CASE WHEN title LIKE '%#{@search_query}%' THEN 1 ELSE 2 END, updated_at DESC"))
      )

      formatted_notes = notes.map do |note|
        {
          id: note.id,
          title: note.title,
          content_preview: note.content.truncate(100),
          created_at: note.created_at,
          updated_at: note.updated_at
        }
      end

      {
        notes: formatted_notes,
        total_items: notes.total_entries,
        total_pages: notes.total_pages
      }
    end
  end
end
