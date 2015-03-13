require 'json/ld'
require 'rdf/turtle'

module Ladder
  module Resource
    module Serializable
      ##
      # Return a Turtle representation for the resource
      #
      # @see ActiveTriples::Resource#dump
      #
      # @param [Hash] opts options to pass to ActiveTriples
      # @option opts [Boolean] :related whether to include related resources (default: false)
      # @return [String] a serialized Turtle version of the resource
      def as_turtle(opts = { related: false })
        update_resource(opts.slice :related).dump(:ttl, { standard_prefixes: true }.merge(opts))
      end

      ##
      # Return a JSON-LD representation for the resource
      #
      # @see ActiveTriples::Resource#dump
      #
      # @param [Hash] opts options to pass to ActiveTriples
      # @option opts [Boolean] :related whether to include related resources (default: false)
      # @return [Hash] a serialized JSON-LD version of the resource
      def as_jsonld(opts = { related: false })
        JSON.parse update_resource(opts.slice :related).dump(:jsonld, { standard_prefixes: true }.merge(opts))
      end

      ##
      # Return a framed, compacted JSON-LD representation
      # by embedding related objects from the graph
      #
      # NB: Will NOT embed related objects with same @type.
      # Spec under discussion, see https://github.com/json-ld/json-ld.org/issues/110
      #
      # @return [Hash] a serialized JSON-LD version of the resource
      def as_framed_jsonld
        json_hash = as_jsonld related: true

        context = json_hash['@context']
        frame = { '@context' => context }
        frame['@type'] = type.first.pname unless type.empty?

        JSON::LD::API.compact(JSON::LD::API.frame(json_hash, frame), context)
      end

      ##
      # Return a qname-based JSON representation
      #
      # @param [Hash] opts options for serializaiton
      # @option opts [Boolean] :related whether to include related resources
      # @return [Hash] a serialized 'qname' version of the resource
      def as_qname(opts = {})
        qname_hash = type.empty? ? {} : { rdf: { type: type.first.pname } }

        resource_class.properties.each do |field_name, property|
          ns, name = property.predicate.qname
          qname_hash[ns] ||= {}

          if relations[field_name]
            qname_hash[ns][name] = opts[:related] ? send(field_name).to_a.map(&:as_qname) : send(field_name).to_a.map { |obj| "#{obj.class.name.underscore.pluralize}:#{obj.id}" }
          end

          if fields[field_name]
            qname_hash[ns][name] = read_attribute(field_name)
          end

          # Remove empty/null values
          qname_hash[ns].delete_if { |_k, v| v.blank? }
        end

        # Insert labels for boosting search score
        { rdfs: { label: update_resource(opts.slice :related).rdf_label } }.merge qname_hash
      end
    end
  end
end
