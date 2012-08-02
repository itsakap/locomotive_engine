module Locomotive
  class SitePresenter < BasePresenter

    delegate :name, :locales, :enabled_plugins, :subdomain, :domains, :robots_txt, :seo_title, :meta_keywords, :meta_description, :domains_without_subdomain, :to => :source

    def domain_name
      Locomotive.config.domain
    end

    def memberships
      self.source.memberships.map { |membership| membership.as_json(self.options) }
    end

    def enabled_plugins
      self.source.enabled_plugins.collect(&:plugin_id)
    end

    def included_methods
      super + %w(name locales enabled_plugins domain_name subdomain domains robots_txt seo_title meta_keywords meta_description domains_without_subdomain memberships)
    end

    def as_json_for_html_view
      methods = included_methods.clone - %w(memberships)
      self.as_json(methods)
    end

  end
end
