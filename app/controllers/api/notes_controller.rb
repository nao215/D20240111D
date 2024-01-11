module Api
  class NotesController < Api::BaseController
    before_action :doorkeeper_authorize!
    before_action :validate_user_and_params, only: :index

    # GET /api/notes
    def index
      # The actual listing of notes is now handled in the validate_user_and_params before_action
      # This block is now empty because the logic has been moved to the validate_user_and_params method
    end

    # GET /api/notes/:note_id
    def show
      begin
        note_id = params[:note_id]
        note = Note.find(note_id)
        if note
          render json: {
            id: note.id,
            title: note.title,
            content: note.content,
            created_at: note.created_at,
            updated_at: note.updated_at
          }, status: :ok
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Note not found' }, status: :not_found
      end
    end

    # PATCH/PUT /api/notes/:note_id
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
        }, status: :ok
      else
        error_response({ message: 'Note not found or not owned by user' }, :not_found)
      end
    end

    # DELETE /api/notes/:id
    def destroy
      note_id = params[:id]
      begin
        deleted_note = NoteService::Delete.new(current_user, note_id).delete_note
        if deleted_note
          render json: { message: I18n.t('notes.delete.success') }, status: :ok
        else
          render json: { error: I18n.t('notes.delete.failure') }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound => e
        render json: { error: e.message }, status: :not_found
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end
    end

    private

    def validate_user_and_params
      user_id = params[:user_id].to_i
      page = params[:page].to_i
      limit = params[:limit].to_i

      unless User.exists?(user_id)
        return render json: { error: 'User not found.' }, status: :bad_request
      end

      unless params[:page].match?(/^\d+$/) && page > 0
        return render json: { error: 'Page must be greater than 0.' }, status: :bad_request
      end

      unless params[:limit].match?(/^\d+$/)
        return render json: { error: 'Wrong format.' }, status: :bad_request
      end

      notes_service = NotesService::Index.new(user_id, page: page, per_page: limit)
      notes_service.call
      notes = notes_service.notes
      total_pages = notes_service.total_pages

      render json: {
        status: 200,
        notes: notes,
        total_pages: total_pages,
        limit: limit,
        page: page
      }, status: :ok
    end

    def error_response(error_hash, status)
      render json: error_hash, status: status
    end
  end
end
