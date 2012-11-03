module Kaminari::Helpers

  module SinatraHelpers

    class ActionViewTemplateProxy

      def render(*args)
        base = ActionView::Base.new.tap do |a|
          a.view_paths << File.join(Padrino.root, 'app/views')
#          a.view_paths << File.expand_path('../../../../app/views', __FILE__)
        end
        base.render(*args)
      end

      def paginate(scope, options = {}, &block)
        current_path = env['PATH_INFO'] rescue nil
        current_params = Rack::Utils.parse_nested_query(env['QUERY_STRING']).symbolize_keys rescue {}
        paginator = Kaminari::Helpers::Paginator.new(
            ActionViewTemplateProxy.new(:current_params => current_params, :current_path => current_path, :param_name => options[:param_name] || Kaminari.config.param_name),
            options.reverse_merge(:current_page => scope.current_page, :total_pages => scope.total_pages, :per_page => scope.limit_value, :param_name => Kaminari.config.param_name, :remote => false)
        )
        paginator.to_s
      end
    end

  end

end
