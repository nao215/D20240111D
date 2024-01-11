module Api
  class NotesController < Api::BaseController
    before_action :doorkeeper_authorize!

    def index
      user_id = params[:user_id]

      return render json: { error: I18n.t('common.errors.unauthorized_error') }, status: :unauthorized unless user_id

      begin
        notes_service = NotesService::Index.new(user_id)
        notes = notes_service.list_user_notes
        total_items = notes.size
        total_pages = (total_items / notes_service.per_page.to_f).ceil

        render json: {
          notes: notes.as_json(only: [:id, :title, :content, :created_at, :updated_at]),
          total_items: total_items,
          total_pages: total_pages
        }, status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end
    end

    def update
      note_id = params[:note_id]
      title = params[:title]
      content = params[:content]

      if title.blank? || content.blank?
        return error_response({ message: 'Title and content cannot be empty' }, :unprocessable_entity)
      end

      note = NoteService::Update.update_note(note_id, title, content, current_resource_owner)

      if note
        render json: {
          message: 'Note updated successfully',
          note: {
            id: note.id,
            title: note.title,
            content: note.content,
            created_at: note.created_at,
            updated_at: note.updated_at
          }
        }
      else
        error_response({ message: 'Note not found or not owned by user' }, :not_found)
      end
    end
  end
end
