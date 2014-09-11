json.array!(@tools) do |tool|
  json.extract! tool, :id, :name, :classifier_id, :image
  json.url tool_url(tool, format: :json)
end
