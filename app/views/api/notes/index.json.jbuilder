class NotesController < ApplicationController
  # ... other necessary methods and actions ...

  def index
    @notes = Note.all # Assuming @notes is assigned somewhere in the controller
    @total_pages = 5 # Assuming @total_pages is assigned somewhere in the controller
    @limit = 10 # Assuming @limit is assigned somewhere in the controller
    @page = 1 # Assuming @page is assigned somewhere in the controller

    json.status 200
    json.notes @notes do |note|
      json.id note.id
      json.title note.title
      json.content note.content
      json.user_id note.user_id
      json.created_at note.created_at.iso8601
      json.updated_at note.updated_at.iso8601
    end

    json.total_pages @total_pages
    json.limit @limit
    json.page @page
  end

  # ... other necessary methods and actions ...
end
