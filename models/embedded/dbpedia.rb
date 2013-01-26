class DBpedia
  include Model::Embedded
  bind_to Vocab::DBpedia, :type => Array
  embedded_in :resource
end