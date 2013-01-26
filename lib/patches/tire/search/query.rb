module Tire

  module Search

    class Query

      def ids(values, type=nil)
        if type
          @value = { :ids => { :values => values, :type => type }  }
        else
          @value = { :ids => { :values => values }  }
        end
      end

    end

  end

end