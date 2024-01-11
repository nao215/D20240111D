json.status 201
json.note do
  json.id @note.id
  json.user_id @note.user_id
  json.title @note.title
  json.content @note.content
  json.created_at @note.created_at.iso8601
  json.updated_at @note.updated_at.iso8601
end
