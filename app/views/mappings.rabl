cache @mappings

node :mappings do
  @mappings.map do |mapping|
    h = mapping.as_document.symbolize_keys_recursive
    h = h.except(:_id, :created_at, :updated_at) unless !! @opts[:all_keys]
    h
  end
end

node :total do
  @mappings.size
end
