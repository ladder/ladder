cache @mapping

node do
  h = @mapping.as_document.symbolize_keys_recursive
  h = h.except(:_id, :created_at, :updated_at) unless !! @opts[:all_keys]
  h
end