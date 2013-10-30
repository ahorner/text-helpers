require_relative '../../test_helper'

describe TextHelpers::Translation do
  before do
    @helper = Object.send(:include, TextHelpers::Translation).new
  end
  describe "given a stored I18n lookup" do
    before do
      @scoped_text = "Scoped lookup"
      @global_text = "Global lookup"

      I18n.backend.store_translations :en, {
        test_key: @global_text,
        test: {
          test_key: "*#{@scoped_text}*",
          interpolated_key: "Global? (!test_key!)"
        }
      }
    end

    describe "for a specified scope" do
      before do
        @helper.define_singleton_method :translation_scope do
          'test'
        end
      end

      it "looks up the text for the key in a scope derived from the call stack" do
        assert_equal "*#{@scoped_text}*", @helper.text(:test_key)
      end

      it "converts the text to HTML via Markdown" do
        assert_equal "<p><em>#{@scoped_text}</em></p>\n", @helper.html(:test_key)
      end

      it "removes the enclosing paragraph with :inline" do
        assert_equal "<em>#{@scoped_text}</em>\n", @helper.html(:test_key, inline: true)
      end

      it "interpolates values wrapped in !!" do
        assert_equal "Global? (#{@global_text})", @helper.text(:interpolated_key)
      end
    end

    describe "when no valid scope is provided" do
      before do
        @helper.define_singleton_method :translation_scope do
          'nonexistent'
        end
      end

      it "defaults to a globally-defined value for the key" do
        assert_equal @global_text, @helper.text(:test_key)
      end
    end
  end
end
