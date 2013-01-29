class Bibo
  include Model::Embedded
  bind_to Vocab::Bibo, :type => Array, :localize => true, :only => [:isbn, :issn, :lccn, :oclcnum, :upc, :doi, :uri]
  embedded_in :resource
end