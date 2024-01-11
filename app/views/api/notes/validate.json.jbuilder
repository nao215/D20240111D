json.error do
  json.title "The title cannot exceed 200 characters." if @note.title.length > 200
  json.content "The content cannot exceed 10000 characters." if @note.content.length > 10000
end if @note.errors.any?

json.status 200 unless @note.errors.any?
json.message "Note input is valid." unless @note.errors.any?
