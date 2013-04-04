collection @files, :root => :files, :object_root => false
cache @files

node do |file|
  file.as_document
end