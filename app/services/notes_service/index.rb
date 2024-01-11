# frozen_string_literal: true

require 'app/models/note.rb'

module NotesService
  class Index
    attr_accessor :user_id, :notes, :total_items, :total_pages

    def initialize(user_id, params = {})
      @user_id = user_id
      @params = params
    end

    def call
      authenticate_user
      retrieve_notes
      format_response
    rescue StandardError => e
      { error: e.message }
    end

    private

    def authenticate_user
      # Assuming there's a method to authenticate the user
      # Placeholder for authentication logic
    end

    def retrieve_notes
      @notes = Note.where(user_id: @user_id).order(updated_at: :desc)
      if @params[:page] && @params[:per_page]
        @notes = @notes.page(@params[:page]).per(@params[:per_page])
        @total_items = @notes.total_count
        @total_pages = @notes.total_pages
      end
    end

    def format_response
      if @notes.empty?
        { message: 'No notes available.' }
      elsif @params[:page] && @params[:per_page]
        {
          notes: @notes.map do |note|
            {
              id: note.id,
              title: note.title,
              content_preview: note.content[0...100],
              updated_at: note.updated_at
            }
          end,
          total_items: @total_items,
          total_pages: @total_pages
        }
      else
        @notes.map do |note|
          {
            id: note.id,
            title: note.title,
            content_preview: note.content[0...100],
            updated_at: note.updated_at
          }
        end
      end
    end
  end
end
