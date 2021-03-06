# DOC:
# We use Helper Methods for tree building,
# because it's faster than View Templates and Partials

# SECURITY note
# Prepare your data on server side for rendering
# or use h.html_escape(node.content)
# for escape potentially dangerous content
module RenderExpandableTreeHelper
  module Render 
    class << self
      attr_accessor :h, :options

      def render_node(h, options)
        options[:edition] = Eda::Application.config.emily['default_edition'] unless options[:edition]
        @h, @options = h, options
        node = options[:node]

        "
          <li data-node-id='#{ node.id }'>
            <div class='item'>
              #{"<i class='handle'></i>" if h.user_signed_in? && h.current_user == options[:edition].owner}
              #{"<b class='expand plus'>+</b>" unless node.leaf?}
              #{"<i class='preview' data-image-filename='#{node.nestable.url}'>Pre</i>" if node.nestable && node.nestable.url}
              #{ show_link }
              #{ controls }
            </div>
            #{ children }
          </li>
        "
      end

      def show_link
        node = options[:node]
        ns   = options[:namespace]
        if node.is_a? ImageSet
            if node.root.is_a?(Collection) && !node.leaf?
                url = h.collection_image_set_url(node.root, node)
            else
                url = h.edition_image_set_url(options[:edition], node)
            end
        elsif node.is_a? WorkSet
            url = h.image_set_path_from_work(node.work)
        elsif node.is_a? Collection
            url = h.collection_url(node)
        else
            url  = h.url_for(ns + [node])
        end
        title_field = options[:title]

        "<h4>#{ h.link_to(node.send(title_field), url) }</h4>"
      end

      def controls
          return unless h.user_signed_in? && h.current_user == options[:edition].owner
        node = options[:node]

        edit_path = h.url_for(:controller => options[:klass].pluralize, :action => :edit, :id => node)
        show_path = h.url_for(:controller => options[:klass].pluralize, :action => :show, :id => node)

        "
          <div class='controls'>
            #{ h.link_to 'Edit', edit_path, :class => :edit }
          </div>
        "
      end

      def children
        unless options[:children].blank?
          "<ol class='nested_set'>#{ options[:children] }</ol>"
        end
      end

    end
  end
end
