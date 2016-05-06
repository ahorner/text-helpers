module TextHelpers
  class Railtie < Rails::Railtie
    config.text_helpers = ActiveSupport::OrderedOptions.new
    config.text_helpers.raise_on_missing_translations = Rails.env.test? || Rails.env.development?

    initializer "text_helpers.action_view.extend_base" do
      ActionView::Base.class_eval do
        include TextHelpers::Translation

        # Public: Derive a translation scope from the current view template.
        #
        # Determines an I18n-friendly scope for the current view file when possible,
        # or falls back to "views.<controller>.<action>"
        #
        # Returns a String.
        def translation_scope
          matcher = /(?<path>.*)\/_?(?<view>[^\/.]+)(?<extension>\.html\.haml)?/
          info = matcher.match(@virtual_path)

          if info
            path = info[:path].gsub('/', '.')
            "views.#{path}.#{info[:view]}"
          else
            "views.#{params[:controller]}.#{params[:action]}"
          end
        end
      end
    end

    initializer "text_helpers.action_mailer.extend_base" do
      ActionMailer::Base.class_eval do
        include TextHelpers::Translation

        # Public: Provides a scope for I18n lookups.
        #
        # Should look like `mailers.<mailer>.<action>`
        #
        # Returns a String.
        def translation_scope
          "mailers.#{mailer_name.tr("/", ".").sub("_mailer", "")}.#{action_name}"
        end
      end
    end

    initializer "text_helpers.action_controller.extend_base" do
      ActionController::Base.class_eval do
        include TextHelpers::Translation

        # Public: Provides a scope for I18n lookups.
        #
        # Should look like `controllers.<controller_name>`.
        #
        # Returns a String.
        def translation_scope
          "controllers.#{params[:controller]}"
        end
      end
    end

    initializer "text_helpers.i18n.add_load_paths" do |app|
      locales = Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s
      app.config.i18n.load_path += Dir[locales]
    end

    initializer "text_helpers.setup_exception_handling", after: 'after_initialize' do
      next unless config.text_helpers.raise_on_missing_translations

      if config.respond_to?(:action_view)
        config.action_view.raise_on_missing_translations = true
      end

      TextHelpers.install_i18n_exception_handler
    end
  end
end
