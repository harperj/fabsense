json.array!(@tutorial_ingredients) do |tutorial_ingredient|
  json.extract! tutorial_ingredient, :id, :tutorial_id, :tool_id, :order_marker
  json.url tutorial_ingredient_url(tutorial_ingredient, format: :json)
end
