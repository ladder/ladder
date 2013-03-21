collection @models, :root => @models.first.class.to_s.underscore.pluralize, :object_root => false
cache @models

node do |m|
  h = m.to_normalized_hash(@opts)
  h[:_id] = m.id
  h[:md5] = Digest.hexencode(m.md5.to_s)
  h[:version] = m.version
  h
end