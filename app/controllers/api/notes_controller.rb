module Api
  class NotesController < ApplicationController
    include Pundit::Authorization
    before_action :doorkeeper_authorize!
    before_action :validate_user_and_params, only: :index
    before_action :doorkeeper_authorize!, only: [:validate]
    include NotesService
    require_relative '../../services/notes_service/index'
    require 'app/models/note.rb'
    require 'app/policies/note_policy.rb'

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
      title = params[:note][:title] || params[:title]
      content = params[:note][:content] || params[:content]

      # Validate note_id as a number
      unless note_id =~ /\A\d+\z/
        return error_response({ error: 'Note ID must be a number.' }, :unprocessable_entity)
      end

      # Validate title length
      return error_response({ error: 'Title cannot exceed 200 characters.' }, :unprocessable_entity) if title.length > 200

      # Validate content length
      return error_response({ error: 'Content cannot exceed 10000 characters.' }, :unprocessable_entity) if content.length > 10000

      begin
        note = Note.find(note_id)
        authorize note, policy_class: NotePolicy

        note_service = NoteService::Update.new
        updated_note = note_service.update_note(note_id: note_id, title: title, content: content, user: current_resource_owner)

        return render json: {
          status: 200,
          note: {
            id: updated_note.id,
            title: updated_note.title,
            content: updated_note.content,
            user_id: updated_note.user_id,
            created_at: updated_note.created_at,
            updated_at: Time.current
          }
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        error_response({ error: 'Note not found' }, :not_found)
      rescue Pundit::NotAuthorizedError
        error_response({ error: 'Not authorized to update this note' }, :forbidden)
      rescue StandardError => e
        error_response({ error: e.message }, :internal_server_error)
      end
    end

    # POST /api/notes
    def create
      title = params[:title]
      content = params[:content]
      user_id = params[:user_id]

      if title.blank?
        return error_response({ message: 'The title is required.' }, :unprocessable_entity)
      elsif title.length > 200
        return error_response({ message: 'The title cannot exceed 200 characters.' }, :unprocessable_entity)
      elsif content.blank?
        return error_response({ message: 'The content is required.' }, :unprocessable_entity)
      elsif user_id.blank? || !user_id.is_a?(Integer)
        return error_response({ message: 'User ID is required and must be an integer.' }, :unprocessable_entity)
      end

      result = NotesService::Create.new(user_id: user_id, title: title, content: content).call

      if result[:success]
        render json: { status: 201, note: result[:note] }, status: :created
      else
        error_response({ message: result[:message] }, :unprocessable_entity)
      end
    end

    # DELETE /api/notes/:id
    def destroy
      note_id = params[:id].to_i

      return render json: { error: "Wrong format." }, status: :bad_request unless note_id.is_a?(Integer)

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

    # GET /api/notes/search
    def search
      keyword = params[:keyword]
      date = params[:date]
      page = params[:page].to_i
      limit = params[:limit].to_i

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

      unless page.is_a?(Numeric) && page > 0
        return render json: { error: "Page must be a number and greater than 0." }, status: :bad_request
      end

      unless limit.is_a?(Numeric)
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

    # POST /api/notes/validate
    def validate
      title = params[:title]
      content = params[:content]

      if title.length > 200
        return error_response({ message: "The title cannot exceed 200 characters." }, :unprocessable_entity)
      elsif content.length > 10000
        return error_response({ message: "The content cannot exceed 10000 characters." }, :unprocessable_entity)
      end

      policy = NotePolicy.new(current_resource_owner, Note.new)
      unless policy.create?
        return error_response({ message: "Not authorized to create or update notes" }, :unauthorized)
      end

      render json: { status: 200, message: "Note input is valid." }, status: :ok
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
