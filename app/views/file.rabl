object @file
cache @file

node do |f|
  h = f.as_document.to_hash.except('md5')
  h[:md5] = Digest.hexencode(f.md5.to_s)
  h
end