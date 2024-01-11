if @error_message.present?
  json.error @error_message
else
  json.status 200
  json.note do
    json.id @note.id
    json.content @note.content
    json.updated_at @note.updated_at.iso8601
  end
end
