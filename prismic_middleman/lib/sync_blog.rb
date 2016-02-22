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

      class_option :lang,
                    type: :string,
                    aliases: '-L',
                    desc: 'The language to create the post with (defaults to I18n.default_locale if avaliable)'

      class_option :blog,
                    type: :string,
                    aliases: '-B',
                    desc: 'The name of the blog to create the post inside (for multi-blog apps, defaults to the only blog in single-blog apps)'

      def prismic (type='blog')
            shared_instance.logger.info "  Prismic Sync: Start type: " + type

            prismic_middleman = shared_instance.config[:prismic_middleman]
            prismic_middleman_options = prismic_middleman.options[:conf][type.to_s]


            prismic_middleman.prismic_search_form(type.to_s).each do |document|


            if type == 'news'
              @title = document["news.title"].as_text
              @date  = document["news.date"].value
              @slug  = document.slug || safe_parameterize(@title)
              @image  = document["news.image"].get_view('wide').url
              @body  = document["news.body"].as_html(nil)
              @abstract  = document["news.abstract"].as_text
              @fonte  = document["news.fonte"].as_text
            end

            if type == 'blog'
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

              callToActions = document.get_group('blog.calltoaction')

              @calltoactionArray = [];

              if callToActions
                callToActions.each do |cta|
                  @calltoactionArray = cta;
                end
              end

            end

            path_template = uri_template prismic_middleman_options['permalink']
            params = date_to_params(@date).merge(category: @category, title: @slug)
            article_path = apply_uri_template path_template, params

            template prismic_middleman_options['template'], File.join(shared_instance.source_dir, article_path + prismic_middleman_options['default_extension']), force: true
          end

          shared_instance.logger.info " Contentful Sync: Done!"
      end

      private
        def shared_instance
                @shared_instance ||= ::Middleman::Application.new do
                end
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

    # Add to CLI
    Base.register(Middleman::Cli::SyncBlog, 'prismic', 'prismic [options]', 'Synchronize Prismic blog posts')


  end
end