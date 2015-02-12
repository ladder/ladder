require 'json/ld'

module Ladder
  module Resource
    module Serializable
      ##
      # Return JSON-LD representation
      #
      # @see ActiveTriples::Resource#dump
      #
      # TODO: documentation
      # @param [Type] name1 more information
      # @param [Type] name2 more information
      # @return [Type, nil] describe return value(s)
      def as_jsonld(opts = {})
        JSON.parse update_resource(opts.slice :related).dump(:jsonld, { standard_prefixes: true }.merge(opts))
      end

      ##
      # Return a framed, compacted JSON-LD representation
      # by embedding related objects from the graph
      #
      # NB: Will NOT embed related objects with same @type.
      # Spec under discussion, see https://github.com/json-ld/json-ld.org/issues/110
      #
      # TODO: documentation
      # @param [Type] name1 more information
      # @param [Type] name2 more information
      # @return [Type, nil] describe return value(s)
      def as_framed_jsonld
        json_hash = as_jsonld related: true

        context = json_hash['@context']
        frame = { '@context' => context }
        frame['@type'] = type.first.pname unless type.empty?

        JSON::LD::API.compact(JSON::LD::API.frame(json_hash, frame), context)
      end

      ##
      # Generate a qname-based JSON representation
      #
      #
      # TODO: documentation
      # @param [Type] name1 more information
      # @param [Type] name2 more information
      # @return [Type, nil] describe return value(s)
      def as_qname(opts = {})
        qname_hash = type.empty? ? {} : { rdf: { type: type.first.pname } }

        resource_class.properties.each do |field_name, property|
          ns, name = property.predicate.qname
          qname_hash[ns] ||= Hash.new

          if relations.keys.include? field_name
            object = send(field_name)
            if opts[:related]
              qname_hash[ns][name] = object.to_a.map(&:as_qname)
            else
              qname_hash[ns][name] = object.to_a.map { |obj| "#{obj.class.name.underscore.pluralize}:#{obj.id}" }
            end
          elsif fields.keys.include? field_name
            qname_hash[ns][name] = read_attribute(field_name)
          end
        end

        qname_hash
      end
    end
  end
end
