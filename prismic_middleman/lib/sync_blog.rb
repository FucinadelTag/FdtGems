require 'middleman-core/cli'
require 'date'
require 'middleman-blog/uri_templates'

module Middleman
  module Cli
    # This class provides an "contentful" command for the middleman CLI.
    class SyncBlog < Thor
      include Thor::Actions
      include ::Middleman::Blog::UriTemplates

      check_unknown_options!

      namespace :prismic

      def self.source_root
        ENV['MM_ROOT']
      end

      # Tell Thor to exit with a nonzero exit code on failure
      def self.exit_on_failure?
        true
      end

      desc "prismic", "Synchronize Prismic blog posts"
      method_option "lang",
        aliases: "-l",
        desc: "The language to create the post with (defaults to I18n.default_locale if avaliable)"
      method_option "blog",
        aliases: "-b",
        desc: "The name of the blog to create the post inside (for multi-blog apps, defaults to the only blog in single-blog apps)"
      def prismic
        prismic_middleman = shared_instance.prismic_middleman
        prismic_middleman_middleman_options = prismic_middleman.options

        if shared_instance.respond_to? :blog
          shared_instance.logger.info "  Contentful Sync: Start..."

          prismic_middleman.prismic_search_form().each do |document|

            author = prismic_middleman.get_document(document["blog.author"].id);
            #image = prismic_middleman.get_document(document["blog.image"].id);

            @title = document["blog.title"].as_text
            @slug  = document.slug || safe_parameterize(@title)
            @autore  = author["author.full_name"].as_text
            @abstract  = document["blog.abstract"].as_text
            @date  = document["blog.date"].value
            @tags  = document.tags
            @image  = document["blog.image"].get_view('wide').url
            @category = document["blog.category"].slug
            @body  = document["blog.body"].as_html(nil)

            blog_inst = shared_instance.blog(options[:blog])

            path_template = blog_inst.source_template
            params = date_to_params(@date).merge(category: @category, title: @slug)
            article_path = apply_uri_template path_template, params

            template prismic_middleman.options.new_article_template, File.join(shared_instance.source_dir, article_path + blog_inst.options.default_extension)
          end

          shared_instance.logger.info " Contentful Sync: Done!"
        else
          raise Thor::Error.new "You need to activate the blog extension in config.rb before you can create an article"
        end
      end

      private
        def shared_instance
          @shared_instance ||= ::Middleman::Application.server.inst
        end

        def value_from_object(object, mapping)
          if ( mapping.is_a?(Symbol) || mapping.is_a?(String) ) && object.respond_to?(mapping)
            object.send(mapping)
          elsif mapping.is_a?(Proc)
            object.instance_exec(object, &mapping)
          else
            shared_instance.logger.warn "Warning - Unknown mapping (#{mapping}) for object (#{object.class}) with ID (#{object.id})"
            nil
          end
        end
    end

  end
end