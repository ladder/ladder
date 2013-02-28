class DBpedia
  include Model::Embedded

  bind_to Vocab::DBpedia, :type => Array, :localize => true

  embedded_in :resource
  embedded_in :agent
  embedded_in :concept

  track_history :on => Vocab::DBpedia.properties
end