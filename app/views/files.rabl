cache @files

node :files do
  @files.map(&:as_document)
end

node :total do
  @files.size
end
