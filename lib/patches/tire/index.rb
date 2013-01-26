module Tire

  class Index

    def get_id_from_document(document)
      old_verbose, $VERBOSE = $VERBOSE, nil # Silence Object#id deprecation warnings
      id = case
             when document.is_a?(Hash)
               document[:_id] || document['_id'] || document[:id] || document['id']
             when document.respond_to?(:id) && document.id != document.object_id
               document.id
           end
      $VERBOSE = old_verbose
      id.to_s
    end

  end

end