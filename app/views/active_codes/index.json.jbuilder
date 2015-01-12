json.array!(@active_codes) do |active_code|
  json.extract! active_code, :id
  json.url active_code_url(active_code, format: :json)
end
