collection @files, :root => :files, :object_root => false
cache @files

node do |file|
  partial('file', :object => file)
end