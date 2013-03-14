class Bibframe
  include Model::Embedded

  bind_to Vocab::Bibframe, :type => Array, :localize => true, :only => []

  # enable camelCase field aliases
  Vocab::Bibframe.aliases.each do |name, new|
    alias_method new, name if fields.map(&:first).include? name.to_s
  end

  embedded_in :resource
  embedded_in :agent
  embedded_in :concept

  track_history :on => Vocab::Bibframe.properties#, :scope => :resource
end