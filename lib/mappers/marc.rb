module Mapper
  class Marc < Mapper

    def self.content_types
      ['application/marc', 'application/marc+xml']
    end

    def perform(file_id)
      @file = Mongoid::GridFS.get(file_id)

      case @file.content_type
        when 'application/marc'
          # parse MARC data and return an array of File objects
          records = MARC::ForgivingReader.new(StringIO.new(@file.data), :invalid => :replace) # TODO: may wish to include encoding options

        when 'application/marc+xml'
          # parse MARCXML into records
          records = MARC::XMLReader.new(StringIO.new(@file.data), :parser => :nokogiri)

        else
          raise ArgumentError, "Unsupported content type : #{@file.content_type}"
      end

      # split MARC/MARCXML file into MARCHASH records
      records.each do |marc_record|
        # create a new MARCHASH file
        file = Mongoid::GridFS.put(StringIO.new(marc_record.to_marchash.to_json), :content_type => 'application/marc+json')

        # spawn a Mapper for the record
        Mapper::MarcHash.new.perform(file.id)
      end

      # delete source file
      Mongoid::GridFS.delete(@file.id)
    end

  end
end