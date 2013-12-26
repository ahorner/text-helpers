require "i18n"
require "active_support/core_ext/string/output_safety"
require "github/markdown"

module TextHelpers

  module Translation

    ORPHAN_MATCHER = /\s(?![^<]*>)(\S+\s*<\/(?:p|li)>)/.freeze

    # Public: Get the I18n localized text for the passed key.
    #
    # key     - The desired I18n lookup key.
    # options - A Hash of options to pass through to the lookup.
    #           :orphans - A special option that will prevent the insertion of
    #                      non-breaking space characters at the end of the text
    #                      when set to true.
    #
    # Returns a String resulting from the I18n lookup.
    def text(key, options = {})
      text = I18n.t(key, {
        scope: self.translation_scope,
        default: "!#{key}!"
      }.merge(options))

      # Interpolate any keypaths (e.g., `!some.lookup.path/key!`) found in the text.
      final_text = text.strip.gsub(/!([\w._\/]+)!/) { |match| I18n.t($1) }
      final_text.html_safe
    end

    # Public: Get an HTML representation of the rendered markdown for the passed I18n key.
    #
    # key     - The desired I18n lookup key.
    # options - A Hash of options to pass through to the lookup.
    #           :inline  - A special option that will remove the enclosing <p>
    #                      tags when set to true.
    #           :orphans - A special option that will prevent the insertion of
    #                      non-breaking space characters at the end of each
    #                      paragraph when set to true.
    #
    # Returns a String containing the localized text rendered via Markdown
    def html(key, options = {})
      rendered = GitHub::Markdown.render(text(key, options))

      rendered = options[:orphans] ? rendered : rendered.gsub(ORPHAN_MATCHER, '&nbsp;\1')
      rendered = rendered.gsub(/<\/?p>/, '') if options[:inline]
      rendered.html_safe
    end

    protected

    # Protected: The proper scope for I18n translation.
    #
    # Must be implemented by any classes which include this module.
    #
    # Raises NotImplementedError.
    def translation_scope
      raise NotImplementedError
    end
  end
end
