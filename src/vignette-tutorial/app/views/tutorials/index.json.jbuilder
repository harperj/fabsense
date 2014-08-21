json.array!(@tutorials) do |tutorial|
  json.extract! tutorial, :id, :name
  json.url tutorial_url(tutorial, format: :json)
end
