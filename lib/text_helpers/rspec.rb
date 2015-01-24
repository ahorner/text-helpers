module TextHelpers
  # TextHelpers::RSpec contains some helpers for making testing around i18n
  # easier, especially with tests that may generate keys that map to
  # translations that aren't/should not be present in your production
  # localization files.
  module RSpec
    class << self
      attr_accessor :translation_backend
    end

    # Public: Set up the test translation environment.
    #
    # Should ideally be called in an RSpec `before(:suite)` hook.
    #
    # Returns the new I18n backend.
    def self.setup_spec_translations
      self.translation_backend = I18n::Backend::Simple.new
      I18n.backend = I18n::Backend::Chain.new(self.translation_backend, I18n.backend)
    end

    # Public: Reset the test translations.
    #
    # Clears out any translations added during an example run.
    #
    # Returns nothing.
    def self.reset_spec_translations
      if self.translation_backend.nil?
        raise "translation_backend is nil. Ensure .setup_spec_translations was called"
      end

      self.translation_backend.reload!
    end

    # TextHelpers::RSpec::TestHelpers contains helper methods to be used from
    # within your examples.
    module TestHelpers

      # Public: Set a new translation in the test translations.
      #
      # path   - The path to the key, like 'models.user.attributes.title'.
      # value  - The localized value.
      # locale - The locale the translation should be defined in.
      # scope  - The scope the translation should be defined under.
      #
      # Returns true on success.
      def set_translation(path, value, locale: I18n.locale, scope: nil)
        *hash_keys, last_key = I18n.normalize_keys(nil, path, scope)

        data = {}
        last_hash = hash_keys.inject(data) { |h,k| h[k] = Hash.new }
        last_hash[last_key] = value

        TextHelpers::RSpec.translation_backend.store_translations(locale, data)

        true
      end
    end
  end
end
