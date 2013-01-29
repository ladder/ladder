class DBpedia
  include Model::Embedded
  bind_to Vocab::DBpedia, :type => Array, :localize => true
  embedded_in :resource
end