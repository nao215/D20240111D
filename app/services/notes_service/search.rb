
# frozen_string_literal: true

require 'app/models/note'

module NotesService
  class Search
    def initialize(user_id:, search_query:, page: 1, per_page: 10, date: nil)
      @user_id = user_id
      @search_query = search_query
      @page = page
      @per_page = per_page
      @date = date
    end

    def paginate_notes(notes)
      validate_parameters
      notes.paginate(page: @page, per_page: @per_page)
    end

    def execute
      notes = Note.where(user_id: @user_id)
                  .where('title LIKE :query OR content LIKE :query', query: "%#{@search_query}%")
                  .order(Arel.sql("CASE WHEN title LIKE '%#{@search_query}%' THEN 1 ELSE 2 END, updated_at DESC"))

      notes = filter_by_date(notes) if @date.present?

      notes = paginate_notes(notes)

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

    private

    def validate_parameters
      raise 'Keyword cannot exceed 200 characters.' if @search_query.length > 200
      raise 'Wrong date format.' unless @date.nil? || @date.match(/\A\d{4}-\d{2}-\d{2}\z/)
      raise 'User ID is required.' if @user_id.blank?
      raise 'User ID must be an integer.' unless @user_id.is_a?(Integer)
    end

    def filter_by_date(notes)
      date = Date.parse(@date)
      notes.where('created_at::date = :date OR updated_at::date = :date', date: date)
    rescue ArgumentError
      raise 'Wrong date format.'
    end
  end
end
