require 'middleman-core/cli'
require 'middleman-core/extensions'
require 'date'
require 'middleman-blog/uri_templates'
require 'padrino-helpers'
require 'padrino/rendering'


# CLI Module
module Middleman::Cli
  # A thor task for creating new projects
    class SyncEventi < Thor
        include Thor::Actions
        include ::Middleman::Blog::UriTemplates
        include Padrino::Helpers


        check_unknown_options!

        namespace :syncEventi

        def self.source_root
            ENV['MM_ROOT']
        end

        desc 'syncEventi NAME [options]', 'Sincronizza gli eventi'

        class_option :collection,
                    type: :string,
                    aliases: '-C',
                    desc: 'Il nom della collection di Meteor'

        # The syncPages task
        # @param [String] tag
        def syncEventi(collection='eventi')

            fdtCrsm_middleman = shared_instance.config[:fdtCrm_middleman]

            shared_instance.logger.info "  FdT Crm Sync: Start..."

            dati = fdtCrsm_middleman.get_collection_data (collection)

            file = shared_instance.root + '/data/calendario_corsi.json'

            File.open(file, 'w') { |file| file.write(JSON.pretty_generate(dati)) }

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

    Base.register(Middleman::Cli::SyncEventi, 'syncEventi', 'syncEventi [options]', 'Synchronize eventi da FdT Crm')
    Base.map('syncEventi' => 'syncEventi')

    def self.exit_on_failure?
        true
    end
end