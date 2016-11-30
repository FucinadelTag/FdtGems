require 'middleman-core/cli'
require 'middleman-core/extensions'
require 'date'
require 'middleman-blog/uri_templates'
require 'padrino-helpers'
require 'padrino/rendering'


# CLI Module
module Middleman::Cli
  # A thor task for creating new projects
    class SyncProdotti < Thor
        include Thor::Actions
        include ::Middleman::Blog::UriTemplates
        include Padrino::Helpers


        check_unknown_options!

        namespace :syncProdotti

        def self.source_root
            ENV['MM_ROOT']
        end

        desc 'syncProdotti [options]', 'Sincronizza i prodotti'

        class_option :collection,
                    type: :string,
                    aliases: '-C',
                    desc: 'Il nom della collection di datoCms'

        # The syncPages task
        # @param [String] tag
        def syncProdotti(collection='prodotti')

            datoCms_middleman = shared_instance.config[:datoCms_middleman]

            shared_instance.logger.info "  FdT datoCms Sync: Start..."

            dati = fdtCrsm_middleman.get_collection_data (collection)

            file = shared_instance.root + '/data/prodotti.json'

            jsonData = JSON.pretty_generate(dati);

            File.open(file, 'w:UTF-8') { |file| file.write(jsonData.force_encoding(Encoding::UTF_8)) }

        end

        private
            def shared_instance
                @shared_instance ||= ::Middleman::Application.new do
                end
            end

            def getTemplateName (tamplateName='default')
                'fdt_templates/' + tamplateName.downcase + '.erb'
            end

            def getUriTitle (pageData)
                if pageData['urlType'] == 'Slug'
                    pageData['slug']
                else
                    'index'
                end
            end
    end

    Base.register(Middleman::Cli::SyncProdotti, 'syncProdotti', 'syncProdotti [options]', 'Synchronize prodotti da datoCms')
    Base.map('syncProdotti' => 'syncProdotti')

    def self.exit_on_failure?
        true
    end
end