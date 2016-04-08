# Require core library
require 'middleman-core'
require 'middleman-blog/uri_templates'
require "rest_client"
require 'padrino-helpers'
require 'padrino/rendering'
require 'syncEventi'

# Extension namespace
class FdtcrmMiddleman < ::Middleman::Extension

    include ::Middleman::Blog::UriTemplates


    option :fdtCrm_url, nil, 'The FdT CRM API Url'
    option :new_event_template, 'fdt_templates/eventi.erb', 'Path (relative to project root) to an ERb template that will be used to generate new Contentful articles from the "middleman contentful" command.'



    def initialize(app, options_hash={}, &block)
        # Call super to build options from the options_hash
        super

        app.config[:fdtCrm_middleman] = self

        # set up your extension
        # puts options.my_option
    end


    def get_collection_data (collection='eventi')
        response = RestClient.get options.fdtCrm_url , {:accept => :json}

        my_hash = JSON.parse(response.body)

        return JSON.parse (my_hash['data'])
    end

    # A Sitemap Manipulator
    # def manipulate_resource_list(resources)
    # end

    # module do
    #   def a_helper
    #   end
    # end

    end

    # Register extensions which can be activated
    # Make sure we have the version of Middleman we expect
    # Name param may be omited, it will default to underscored
    # version of class name

    ::Middleman::Extensions.register(:fdtCrm_middleman, FdtcrmMiddleman)
