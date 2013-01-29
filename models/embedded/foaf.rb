class FOAF
  include Model::Embedded
  bind_to RDF::FOAF, :type => Array, :localize => true, :only => [:name, :birthday, :title]
  embedded_in :agent
end