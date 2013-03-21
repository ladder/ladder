object @file
cache @file

node { @file.as_document.to_hash.except('data', 'md5') }

# Convert the MD5 into readable hex
node :md5 do
  Digest.hexencode(@file.md5.to_s)
end