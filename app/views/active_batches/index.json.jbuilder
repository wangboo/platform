json.array!(@active_batches) do |active_batch|
  json.extract! active_batch, :id
  json.url active_batch_url(active_batch, format: :json)
end
