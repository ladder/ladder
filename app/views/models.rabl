cache @models

node @models.empty? ? 'models' : @models.first.class.to_s.underscore.pluralize do
  @models.map do |model|
    h = model.to_normalized_hash(@opts)
    h[:_id] = model.id
    h[:md5] = Digest.hexencode(model.md5.to_s)
    h[:version] = model.version if model.version
    h
  end
end

node :total do
  @models.size
end
