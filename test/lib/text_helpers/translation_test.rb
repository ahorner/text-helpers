require_relative '../../test_helper'

describe TextHelpers::Translation do
  before do
    @helper = Object.send(:include, TextHelpers::Translation).new
  end
  describe "given a stored I18n lookup" do
    before do
      @scoped_text = "Scoped lookup"
      @global_text = "Global lookup"
      @multiline_text = <<-MULTI.gsub(/^[ \t]+/, '')
        This is some multiline text.

        It should include multiple paragraphs.
      MULTI

      @nb_scoped_text = "Scoped&nbsp;lookup"
      @nb_global_text = "Global&nbsp;lookup"

      I18n.backend.store_translations :en, {
        test_key: @global_text,
        multiline_key: @multiline_text,
        test: {
          test_key: "*#{@scoped_text}*",
          list_key: "* #{@scoped_text}",
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
        assert_equal "*#{@nb_scoped_text}*", @helper.text(:test_key)
      end

      it "allows orphaned text with :orphans" do
        assert_equal "*#{@scoped_text}*", @helper.text(:test_key, orphans: true)
      end

      it "converts the text to HTML via Markdown" do
        assert_equal "<p><em>#{@nb_scoped_text}</em></p>\n", @helper.html(:test_key)
      end

      it "handles orphans within HTML list items" do
        expected = <<-EXPECTED.gsub(/^[ \t]+/, '')
        <ul>
        <li>#{@nb_scoped_text}</li>
        </ul>
        EXPECTED

        assert_equal expected, @helper.html(:list_key)
      end

      it "allows orphaned text with :orphans" do
        assert_equal "<p><em>#{@scoped_text}</em></p>\n", @helper.html(:test_key, orphans: true)
      end

      it "correctly eliminates orphans across multiple paragraphs" do
        expected = <<-EXPECTED.gsub(/^[ \t]+/, '')
          <p>This is some multiline&nbsp;text.</p>

          <p>It should include multiple&nbsp;paragraphs.</p>
        EXPECTED
        assert_equal expected, @helper.html(:multiline_key)
      end

      it "removes the enclosing paragraph with :inline" do
        assert_equal "<em>#{@nb_scoped_text}</em>\n", @helper.html(:test_key, inline: true)
      end

      it "correctly combines :orphans and :inline options" do
        assert_equal "<em>#{@scoped_text}</em>\n", @helper.html(:test_key, inline: true, orphans: true)
      end

      it "interpolates values wrapped in !!" do
        assert_equal "Global? (#{@nb_global_text})", @helper.text(:interpolated_key)
      end
    end

    describe "when no valid scope is provided" do
      before do
        @helper.define_singleton_method :translation_scope do
          'nonexistent'
        end
      end

      it "defaults to a globally-defined value for the key" do
        assert_equal @nb_global_text, @helper.text(:test_key)
      end
    end
  end
end
