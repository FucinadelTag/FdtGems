# Require core library
require 'middleman-core'
require "sync_blog"

# Extension namespace
class PrismicMiddleman < ::Middleman::Extension

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

  def prismic_search_form ()
    results = @api.form('everything').query(%([[:d = at(document.type, "#{self.options.defaultDocumentType}")]])).submit(@ref)
    return results
  end

  def get_document(id)
      documents = @api.form("everything")
                     .query("[[:d = at(document.id, \"#{id}\")]]")
                     .submit(@ref)

      documents.length == 0 ? nil : documents.first
    end

  helpers do
    def prismic_search_form ()
        api = Prismic.api (prismic_middleman.options.url);
        ref = api.master();
        results = api.form('everything').query(%([[:d = at(document.type, "#{prismic_middleman.options.defaultDocumentType}")]])).submit(ref)
        return results
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
