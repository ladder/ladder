cache @model

node do
  h = @model.to_normalized_hash(@opts)
  h[:_id] = @model.id
  h[:md5] = Digest.hexencode(@model.md5.to_s)
  h[:version] = @model.version
  h
end