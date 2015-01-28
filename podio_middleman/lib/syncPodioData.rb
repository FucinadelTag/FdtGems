require 'middleman-core/cli'
require 'middleman-core/extensions'
require 'date'


# CLI Module
module Middleman::Cli
  # A thor task for creating new projects
    class SyncPodioData < Thor
        include Thor::Actions


        check_unknown_options!

        namespace :syncPodioData

        def self.source_root
            ENV['MM_ROOT']
        end




        desc 'syncPodioData [options]', 'Sincronizza alcuni dati provenienti da Podio creando pagine statiche'
        method_option 'view_name',
                        aliases: '-N',
                        default: 'consumabili',
                        desc: "La vew di podio che filtra i contenuti"
        # The syncPages task
        # @param [String] tag
        def syncPodioData(view_name='consumabili', templateName='prodotti')

            podio_middleman = shared_instance.podio_middleman

            items = podio_middleman.getView (view_name)


            if items.count > 0

                items.all.each do |item|

                    item_ok = {'title'=>item['title'],'data'=>podio_middleman.getFieldsObject(view_name, item)}

                    writeFile(view_name,item_ok,templateName)

                end

            end

        end



        private

            def writeFile (view_name,item,templateName)

                puts item['data']
                @item = item['data']
                podio_middleman = shared_instance.podio_middleman
                item_path = podio_middleman.getPath(view_name,item)

                pageTemplate = getTemplateName(templateName)
                template pageTemplate, File.join(shared_instance.source_dir, item_path)

            end

            def shared_instance
                @shared_instance ||= ::Middleman::Application.server.inst
            end

            def getTemplateName (tamplateName='default')
                'fdt_templates/' + tamplateName.downcase + '.tt'
            end

            def getUriTitle (pageData)
                if pageData['urlType'] == 'Slug'
                    pageData['slug']
                else
                    'index'
                end
            end

    end

    def self.exit_on_failure?
        true
    end
end