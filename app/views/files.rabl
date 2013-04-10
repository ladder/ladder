cache @files

node :files do
  @files.map do |file|
    h = file.as_document
    h[:model] = file.model if file.model
    h
  end
end

node :total do
  @files.size
end
