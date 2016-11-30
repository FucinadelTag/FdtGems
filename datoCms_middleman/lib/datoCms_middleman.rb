# Require core library
require 'middleman-core'
require 'middleman-blog/uri_templates'
require "rest_client"
require 'padrino-helpers'
require 'padrino/rendering'
require 'syncEventi'

# Extension namespace
class DatocmsMiddleman < ::Middleman::Extension

    include ::Middleman::Blog::UriTemplates


    option :datoCms_api_token, nil, 'Il token per accedere a datoCMS'
    option :datoCms_url, 'https://site-api.datocms.com/', 'Indirizzo di accesso alle api'



    def initialize(app, options_hash={}, &block)
        # Call super to build options from the options_hash
        super

        app.config[:datoCms_middleman] = self

        # set up your extension
        # puts options.my_option
    end


    def get_collection_data (collection='eventi')
        response = RestClient.get options.datoCms_url , {:accept => :json}

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

    ::Middleman::Extensions.register(:datoCms_middleman, DatocmsMiddleman)
