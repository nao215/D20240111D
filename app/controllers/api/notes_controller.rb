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

    # PATCH/PUT /api/notes/:id
    def update
      note_id = params[:id] || params[:note_id]
      title = params[:note].try(:[], :title) || params[:title]
      content = params[:note].try(:[], :content) || params[:content]

      if note_id.blank? || !note_id.to_s.match?(/\A\d+\z/)
        return render json: { error: "Note ID must be a number." }, status: :bad_request
      end

      note_id = note_id.to_i

      if title.present? && title.length > 200
        return render json: { error: "You cannot input more than 200 characters." }, status: :bad_request
      end

      if content.blank?
        return render json: { error: "The content is required." }, status: :bad_request
      end

      update_service = NotesService::Update.new(note_id, current_resource_owner.id, title, content)
      result = update_service.call

      if result[:note_id]
        note = Note.find(result[:note_id])
        render json: {
          status: 200,
          note: {
            id: note.id,
            title: note.title,
            content: note.content,
            updated_at: note.updated_at.iso8601
          }
        }, status: :ok
      elsif result[:error] =~ /not found/
        render json: { error: result[:error] }, status: :not_found
      else
        error_response({ message: 'Note not found or not owned by user' }, :not_found)
      end
    end

    # DELETE /api/notes/:id
    def destroy
      note_id = params[:id]
      unless note_id.to_s.match?(/\A\d+\z/)
        return render json: { error: 'Note ID must be a number.' }, status: :bad_request
      end

      note_id = note_id.to_i

      begin
        note = Note.find(note_id)
        authorize note, policy_class: NotePolicy

        result = NoteService::Delete.new.execute(note_id: note_id, user: current_user)
        if result[:message]
          render json: { status: 200, message: result[:message] }, status: :ok
        elsif result[:error]
          render json: { error: result[:error] }, status: :not_found
        else
          render json: { error: 'Note not found.' }, status: :not_found
        end
      rescue ActiveRecord::RecordNotFound => e
        render json: { error: e.message }, status: :not_found
      rescue Pundit::NotAuthorizedError
        render json: { error: 'User does not have permission to access the resource.' }, status: :forbidden
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

      unless params[:limit].match?(/^\d+$/) && limit > 0
        return render json: { error: 'Limit must be greater than 0.' }, status: :bad_request
      end

      notes_service = NotesService::Index.new(user_id, page: page, per_page: limit)
      notes_service.call
      notes = notes_service.notes
      total_pages = notes_service.total_pages

      render json: {
        status: 200,
        notes: notes.as_json(only: [:id, :title, :content, :created_at, :updated_at]),
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
