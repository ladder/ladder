class Bibo
  include Model::Embedded
  bind_to Vocab::Bibo, :type => Array, :only => [:isbn, :issn, :lccn, :oclcnum, :upc, :doi, :uri]
  embedded_in :resource
end