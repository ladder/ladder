object @model
cache @model

node do
  @model.to_normalized_hash(@opts)
end

# Convert the MD5 into readable hex
node(:md5, :if => !! @opts[:all_keys]) do
  Digest.hexencode(@model.md5.to_s)
end