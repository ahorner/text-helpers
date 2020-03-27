require "text_helpers/version"
require "text_helpers/translation"
require "text_helpers/railtie" if defined?(Rails)

module TextHelpers
  # RaiseExceptionHandler just raises all exceptions, rather than swallowing
  # MissingTranslation ones. It's cribbed almost verbatim from
  # https://guides.rubyonrails.org/i18n.html#using-different-exception-handlers.
  class RaiseExceptionHandler < I18n::ExceptionHandler
    def call(exception, locale, key, options)
      if exception.is_a?(I18n::MissingTranslation) && key.to_s != "i18n.plural.rule"
        raise exception.to_exception
      else
        super
      end
    end
  end

  # Public: Install an instance of TextHelpers::RaiseExceptionHandler as the
  # default I18n exception handler.
  #
  # Returns the handler instance.
  def self.install_i18n_exception_handler
    if I18n.exception_handler
      Rails.logger.warn("Overwriting existing I18n exception handler")
    end

    I18n.exception_handler = RaiseExceptionHandler.new
  end
end
