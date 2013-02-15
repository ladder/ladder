class DBpedia
  include Model::Embedded

  bind_to Vocab::DBpedia, :type => Array, :localize => true

  embedded_in :resource # NB: this is embedded in all models

  track_history :on => Vocab::DBpedia.properties
end