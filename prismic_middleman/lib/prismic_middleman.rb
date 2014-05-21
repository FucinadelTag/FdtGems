# Require core library
require 'middleman-core'
require 'middleman-blog/uri_templates'
require "sync_blog"

# Extension namespace
class PrismicMiddleman < ::Middleman::Extension

    include ::Middleman::Blog::UriTemplates


    option :url, nil, 'The Prismic API Url'
    option :defaultDocumentType, 'blog', 'The Prismic Content Type'

    option :new_article_template, File.expand_path('../commands/article.tt', __FILE__), 'Path (relative to project root) to an ERb template that will be used to generate new Contentful articles from the "middleman contentful" command.'


    option :sync_blog_before_build, false, "Synchronize the blog from Prismic before the build phase"

    def initialize(app, options_hash={}, &block)
        # Call super to build options from the options_hash
        super

        # Require libraries only when activated
        # require 'necessary/library'
        require 'prismic'

        app.set :prismic_middleman, self

        @api = Prismic.api (self.options.url);
        @ref = @api.master();

        # set up your extension
        # puts options.my_option
    end

    def prismic_search_form
        results = @api.form('everything').query(%([[:d = at(document.type, "#{self.options.defaultDocumentType}")]])).submit(@ref)
        return results
    end

    def get_by_tags (*tags)
        documents = @api.form('everything').query(%([[:d = any(document.tags, [\"#{tags[0]}\"])]])).submit(@ref)

        return documents
    end

    def getHomePage ()
        documents = get_by_tags ('home')
        documents.length == 0 ? nil : documents.first
    end

    def getImages (document)
        images = document["block.gallery"]
    end

    def getSections (document)
        sections = document["block.sections"]
    end

    def getSectionsAsHash (document)
        sections = getSections (document)

        sectionsHash = {};

        if (sections && sections.size > 0)
            sections.each_with_index do |section, index|
                title = section['title'].as_text;
                slug = safe_parameterize (title)
                body = section['body'].as_html (nil)

                sectionsHash [index] = {'slug' => slug, 'title' => title , 'body' => body}
            end
        end
        return sectionsHash

    end

    def getKeyValuePairs (document)
        sections = document["block.KeyValuePairs"]
    end

    def getKeyValuePairsAsHash (document)
        keyValuePairs = getKeyValuePairs (document)

        keyValuePairsHash = {'key' => nil, 'value' => nil};

        if (keyValuePairs && keyValuePairs.size > 0)
            keyValuePairs.each_with_index do |keyValuePair, index|
                key = keyValuePair['key'].as_text;
                value = keyValuePair['value']

                keyValuePairsHash [key] = {'key' => key, 'value' => value}
            end
        end
        return keyValuePairsHash

    end

    def getImagesAsHash (document)
        images = getImages (document)

        imagesHash = {};

        if (images && images.size > 0)
            images.each_with_index do |image, index|

                url = image['picture'].get_view('wide').url;
                caption = image['caption'].as_text

                imagesHash [index] = {'url' => url , 'caption' => caption}
            end
        end
        return imagesHash

    end

    def getBlocks (document)
        blocks = document["block.blocks"]
    end

    def getBlockAsHash (document)
        blocks = getBlocks (document)

        blocksHash = {};

        if (blocks && blocks.size > 0)
            blocks.each do |block, index|

                blockDocument = block['link']
                document = get_document (blockDocument.id)
                blocksHash [blockDocument.slug] = getBlockData (document)
            end
        end
        return blocksHash

    end

    def getBlockData (document)
        pageData = {}
        pageData ['title'] =  document["block.title"] == nil ? nil : document["block.title"].as_text
        pageData ['slug'] =  document.slug == nil ? nil : document.slug
        pageData ['abstract'] = document["block.abstract"] == nil ? nil : document["block.abstract"].as_text
        pageData ['body'] =  document["block.body"] == nil ? nil : document["block.body"].as_html(nil)
        pageData ['icona'] =  document["block.icon"] == nil ? nil : document["block.icon"].as_text
        pageData ['images'] = getImagesAsHash (document)
        pageData ['sections'] = getSectionsAsHash (document)
        pageData ['KeyValuePairs'] = getKeyValuePairsAsHash (document)
        pageData ['blocks'] = getBlockAsHash (document)

        return pageData

    end


    def get_document(id)
      documents = @api.form("everything")
                    .query("[[:d = at(document.id, \"#{id}\")]]")
                    .submit(@ref)

      documents.length == 0 ? nil : documents.first
    end

    helpers do
        def prismic
            return prismic_middleman
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

    ::Middleman::Extensions.register(:prismic_middleman, PrismicMiddleman)
