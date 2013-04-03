class Importer

  def self.content_types
    ['application/mods+xml',
     'application/marc',
     'application/marc+xml',
     'application/marc+json']
  end

  def self.perform(io, content_type)
    case content_type
      when 'application/marc+json'
        # normalize MARC-in-JSON
        json = JSON.parse(io.read).to_json
        Model::File.find_or_create_by(:data => json, :content_type => content_type)
      else
        Model::File.find_or_create_by(:data => io.read, :content_type => content_type)
    end
  end

end