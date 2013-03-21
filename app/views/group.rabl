object @group
cache @group

node { @group.to_normalized_hash(@opts) }

node @group.type.underscore.pluralize.to_sym do
  @group.models.only(:id).map(&:id)
end

# Convert the MD5 into readable hex
node(:md5, :if => !! @opts[:all_keys]) do
  Digest.hexencode(@group.md5.to_s)
end