# Require core library
require 'middleman-core'
require 'middleman-blog/uri_templates'
require "syncPodioData"
require "rest_client"
require 'padrino-helpers'
require 'padrino/rendering'

# Extension namespace
class PodioMiddleman < ::Middleman::Extension

    include ::Middleman::Blog::UriTemplates


    option :podio_api_key, nil
    option :podio_api_secret, nil
    option :podio_app_id, nil
    option :podio_app_token, nil
    option :podio_views, nil
    option :podio_templates, nil
    option :podio_fields_to_get, nil

    def initialize(app, options_hash={}, &block)
        # Call super to build options from the options_hash
        super

        # Require libraries only when activated
        # require 'necessary/library'
        require 'podio'

        app.config[:podio_middleman] = self

        Podio.setup(:api_key => options.podio_api_key, :api_secret => options.podio_api_secret)

        Podio.client.authenticate_with_app(options.podio_app_id, options.podio_app_token)
    end

    def getView (view_name)

        podio_view = options.podio_views[view_name]

        items = Podio::Item.find_by_filter_id(options.podio_app_id, podio_view, {"remember" => true})

        return items

    end

    def getFieldsObject (view_name, item)

        array_fields_to_get = options.podio_fields_to_get[view_name]
        reponseObject = Hash.new

        item.fields.each do |field|
            label = field['config']['label']
            slug = field['external_id']
            if array_fields_to_get.include?label
                reponseObject[slug]= {'label'=> label, 'value'=> getFieldValue(field)}
            end
        end

        return reponseObject
    end

    def getFieldValue (field)
        fieldType = field['type']

        case fieldType

            when 'money'
                value = formatMoney (field['values'])
            when 'image'
                value = formatImage (field['values'])
            when 'text'
                value = formatText (field['values'])
            when 'calculation'
                value = formatNumber (field['values'])
            when 'category'
                value = formatCategory (field['values'])

        end

        return value
    end

    def formatText (fieldValue)
        value = fieldValue[0]['value']
        return value
    end

    def formatMoney (fieldValue)
        value =  "%.2f" % fieldValue[0]['value']
        return value
    end

    def formatNumber (fieldValue)
        value =  "%.2f" % fieldValue[0]['value']
        return value
    end

    def formatImage (fieldValue)
        file_id = fieldValue[0]['value']['file_id']
        file_name = fieldValue[0]['value']['name']

        path_file = "source/images/prodotti/#{file_name}"

        File.open(path_file, 'wb') do |downloaded_file|
            file = Podio::FileAttachment.find(file_id)
            downloaded_file.write(file.raw_data())
        end

        path_image = "/images/prodotti/#{file_name}"

        return path_image

    end

    def formatCategory (fieldValue)
        reponseArray = Array.new
        fieldValue.each_with_index do |value, index|
            reponseArray[index] = value['value']['text']
        end
        return reponseArray
    end

    def getPath (view_name,item)
        path_template = uri_template '/store/{category}/{title}.html.erb'
        params = {category: view_name, title: safe_parameterize(item['title'])}
        item_path = apply_uri_template path_template, params

        return item_path

    end


    helpers do
        def podio
            return podio_middleman
        end
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

    ::Middleman::Extensions.register(:podio_middleman, PodioMiddleman)
