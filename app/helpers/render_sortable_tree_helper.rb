# DOC:
# We use Helper Methods for tree building,
# because it's faster than View Templates and Partials

# SECURITY note
# Prepare your data on server side for rendering
# or use h.html_escape(node.content)
# for escape potentially dangerous content
module RenderSortableTreeHelper
  module Render 
    class << self
      attr_accessor :h, :options

      def render_node(h, options)
        @h, @options = h, options
        node = options[:node]

        "
          <li data-node-id='#{ node.id }'>
            <div class='item'>
              <i class='handle'></i>
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
        options[:edition] = Eda::Application.config.emily['default_edition'] unless options[:edition]
        if node.is_a? ImageSet
            if node.root.is_a?(Collection) && !node.leaf?
                url = h.collection_image_set_url(node.root, node)
            else
                url = h.edition_image_set_url(options[:edition], node)
            end
        elsif node.is_a? ReadingList
            url = ''
        elsif node.is_a? WorkSet
            url = h.image_set_path_from_work(node.work)
        elsif node.is_a? Collection
            url = h.collection_url(node)
        else
            url  = h.url_for(ns + [node])
        end
        title_field = options[:title]

        if node.is_a? ReadingList
            "<h4>#{ node.send(title_field) }</h4>"
        else
            "<h4>#{ h.link_to(node.send(title_field), url) }</h4>"
        end
      end

      def controls
        node = options[:node]

        edit_path = h.url_for(:controller => options[:klass].pluralize, :action => :edit, :id => node)
        show_path = h.url_for(:controller => options[:klass].pluralize, :action => :show, :id => node)

        "
          <div class='controls'>
            #{ h.link_to '', edit_path, :class => :edit }
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
