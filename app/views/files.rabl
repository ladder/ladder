collection @files, :root => :files, :object_root => false
cache @files

node do |f|
  h = f.as_document.to_hash.except('data', 'md5')
  h[:md5] = Digest.hexencode(f.md5.to_s)
  h
end