collection @models, :root => @models.empty? ? 'models' : @models.first.class.to_s.underscore.pluralize, :object_root => false
cache @models

node do |model|
  partial('model', :object => model)
end