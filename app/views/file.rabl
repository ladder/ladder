cache @file

node do
  h = @file.as_document
  h[:model] = @file.model if @file.model
  h
end