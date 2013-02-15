class VCard
  include Model::Embedded

  bind_to Vocab::VCard, :type => Array, :localize => true

  # enable camelCase field aliases
  Vocab::VCard.aliases.each do |name, new|
    alias_method new, name if fields.map(&:first).include? name.to_s
  end

  embedded_in :agent

  track_history :on => Vocab::VCard.properties
end