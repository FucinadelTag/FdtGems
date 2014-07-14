require 'middleman-core/cli'
require 'middleman-core/extensions'
require 'date'
require 'middleman-blog/uri_templates'
require 'padrino-helpers'
require 'padrino/rendering'


# CLI Module
module Middleman::Cli
  # A thor task for creating new projects
    class SyncPages < Thor
        include Thor::Actions
        include ::Middleman::Blog::UriTemplates
        include Padrino::Helpers


        check_unknown_options!

        namespace :syncPages

        def self.source_root
            ENV['MM_ROOT']
        end




        desc 'syncPages NAME [options]', 'Create new project NAME'
        method_option 'document_type',
                        aliases: '-T',
                        default: 'default',
                        desc: "Il document type"
        # The syncPages task
        # @param [String] tag
        def syncPages(tag='pages-group')

            prismic_middleman = shared_instance.prismic_middleman

            shared_instance.logger.info "  Prismic Sync: Start..."

            site = prismic_middleman.get_by_tags ('site')
            siteData = prismic_middleman.getBlockData (site.first)

            puts tag



            prismic_middleman.get_by_tags(tag).each do |document|

                pageData = prismic_middleman.getBlockData (document)

                @title = pageData ['title']
                @slug  = pageData ['slug']
                @category = document["block.category"].slug
                @pageData = pageData
                @siteData = siteData



                prismic_inst = shared_instance.prismic_middleman(options[:prismic])


                path_template = uri_template prismic_inst.options.permalink
                params = {category: @category, title: @slug}
                article_path = apply_uri_template path_template, params

                pageTemplate = 'fdt_templates/' + pageData ['pageType'].downcase + '.erb'

                template pageTemplate, File.join(shared_instance.source_dir, article_path + prismic_inst.options.default_extension)
                #print template pageTemplate

            end

        end

        private
            def shared_instance
                @shared_instance ||= ::Middleman::Application.server.inst
            end

    end

    def self.exit_on_failure?
        true
    end
end