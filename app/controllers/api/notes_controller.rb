module Api
  class NotesController < Api::BaseController
    include NotesService
    before_action :doorkeeper_authorize!, except: [:show, :search, :autosave]
    before_action :doorkeeper_authorize!, only: [:create]

    # GET /api/notes
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

    # POST /api/notes
    def create
      user_id = params[:user_id]
      title = params[:title]
      content = params[:content]

      # Validate parameters
      return render json: { error: "User not found." }, status: :bad_request unless User.exists?(user_id)
      return render json: { error: "The title is required." }, status: :bad_request if title.blank?
      return render json: { error: "The content is required." }, status: :bad_request if content.blank?

      # Create note
      notes_service = NotesService::Create.new(user_id: user_id, title: title, content: content)
      result = notes_service.call

      # Handle response
      if result[:success]
        note = Note.find(result[:note_id])
        render json: {
          status: 201,
          note: note.as_json(only: [:id, :user_id, :title, :content, :created_at, :updated_at])
        }, status: :created
      else
        render json: { error: result[:message] }, status: :bad_request
      end
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end

    # DELETE /api/notes/:id
    def destroy
      note_id = params[:id].to_i

      return render json: { error: "Wrong format." }, status: :bad_request unless note_id.is_a?(Integer)

      result = NotesService::Delete.new(current_resource_owner, note_id).delete_note

      if result.is_a?(Hash) && result[:message]
        render json: { status: 200, message: result[:message] }, status: :ok
      elsif result.is_a?(Hash) && result[:error]
        case result[:error]
        when I18n.t('notes.delete.not_authorized')
          render json: { error: result[:error] }, status: :unauthorized
        when I18n.t('notes.delete.not_found')
          render json: { error: result[:error] }, status: :not_found
        else
          render json: { error: result[:error] }, status: :internal_server_error
        end
      else
        render json: { error: I18n.t('notes.delete.failure') }, status: :unprocessable_entity
      end
    end

    # GET /api/notes/search
    def search
      keyword = params[:keyword]
      date = params[:date]
      page = params[:page]
      limit = params[:limit]

      if keyword.present? && keyword.length > 200
        return render json: { error: "Keyword cannot exceed 200 characters." }, status: :bad_request
      end

      begin
        Date.parse(date) if date.present?
      rescue ArgumentError
        return render json: { error: "Wrong date format." }, status: :bad_request
      end

      unless User.exists?(params[:user_id])
        return render json: { error: "User not found." }, status: :bad_request
      end

      unless page.match?(/\A\d+\z/) && page.to_i > 0
        return render json: { error: "Page must be a number and greater than 0." }, status: :bad_request
      end

      unless limit.match?(/\A\d+\z/)
        return render json: { error: "Limit must be a number." }, status: :bad_request
      end

      begin
        search_service = NotesService::Search.new(user_id: current_resource_owner.id, search_query: keyword)
        notes = search_service.execute
        total_items = notes.size
        total_pages = (total_items / limit.to_f).ceil

        paginated_notes = notes.paginate(page: page, per_page: limit)

        render json: {
          status: 200,
          notes: paginated_notes,
          total_pages: total_pages,
          limit: limit,
          page: page
        }, status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end
    end

    # POST /api/notes/autosave
    def autosave
      note_id = params[:id]
      content = params[:content]

      return render json: { error: "Wrong format." }, status: :bad_request unless note_id.is_a?(Integer)
      return render json: { error: "The content is required." }, status: :bad_request if content.blank?

      note = Note.find_by(id: note_id)
      return render json: { error: "Note not found." }, status: :not_found unless note

      authorize note, policy_class: NotePolicy

      autosave_service = NotesService::AutoSave.new(current_resource_owner.id, '', content, note_id)
      result = autosave_service.call

      if result[:error]
        render json: { error: result[:error] }, status: :unprocessable_entity
      else
        note.reload
        render json: {
          status: 200,
          note: {
            id: note.id,
            content: note.content,
            updated_at: note.updated_at
          }
        }, status: :ok
      end
    end

    private

    def error_response(error_hash, status)
      render json: error_hash, status: status
    end
  end
end
