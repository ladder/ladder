class Embed
  include Model::Embedded

  bind_to RDF::SKOS, :type => Array, :localize => true, :only => [:prefLabel, :altLabel, :hiddenLabel, :broader, :narrower]

  embedded_in :test

  track_history
end

class Test
  include Model::Core

  # embedded RDF vocabularies
  embeds_one :embed, class_name: 'Embed', cascade_callbacks: true

  define_scopes
end