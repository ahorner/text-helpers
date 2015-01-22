module TextHelpers

  class Railtie < Rails::Railtie

    initializer "text_helpers.configure_rails_initialization" do

      ActionView::Base.class_eval do
        include TextHelpers::Translation

        protected

        # Protected: Derive a translation scope from the current view template.
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

      ActionMailer::Base.class_eval do
        include TextHelpers::Translation

        protected

        # Protected: Provides a scope for I18n lookups.
        #
        # Should look like `mailers.<mailer>.<action>`
        #
        # Returns a String.
        def translation_scope
          "mailers.#{mailer_name.tr("/", ".").sub("_mailer", "")}.#{action_name}"
        end
      end

      ActionController::Base.class_eval do
        include TextHelpers::Translation

        protected

        # Protected: Provides a scope for I18n lookups.
        #
        # Should look like `controllers.<controller_name>`.
        #
        # Returns a String.
        def translation_scope
          "controllers.#{params[:controller]}"
        end
      end
    end
  end
end
