module Model
  #
  # TODO: refactor this into an Import:: module / class
  #

  class MarcFile < File
    @content_types = ['application/marc', 'application/marc+xml', 'application/marc+json']

    # Class methods
    class << self
      attr_reader :content_types

      def import(data, content_type)
        case content_type
          when 'application/marc'
            parse_marc(data, content_type)
          when 'application/marc+xml'
            parse_marcxml(data, content_type)
          when 'application/marc+json'
            [Model::File.create({:data => data, :content_type => content_type})]
          else
            raise ArgumentError, "Unsupported content type : #{content_type}"
        end
      end

      def parse_marc(marc, content_type)
        files = []

        # parse MARC data and return an array of File objects
        reader = MARC::Reader.new(marc, :invalid => :replace) # TODO: may wish to include encoding options

        reader.each do |record|
          # create a new file for this MARC record
          files << Model::File.create(:data => record.to_marc, :content_type => content_type)
        end

        files
      end

      def parse_marcxml(xml)
        # TODO: NOT IMPLEMENTED YET
        []
      end
    end

  end

end