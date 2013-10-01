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
            url = h.edition_image_set_url(options[:edition], node)
        elsif node.is_a? WorkSet
            url = h.edition_work_set_url(options[:edition], node)
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
            #{ h.link_to 'Delete', show_path, :class => :delete, :method => :delete, :data => { :confirm => 'Are you sure?' } }
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
