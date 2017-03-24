# TextHelpers

`TextHelpers` is a library intended to make working with static text in Rails projects as painless as possible.

Include it in your `Gemfile` with:

```
gem "text_helpers"
```

## Suggested Use

All static text should be placed in locale files, in a directory structure mirroring the app directory structure. The text for `app/views/some/_partial.html.haml` would go in `config/locales/views/some/partial.en.yml`, for example. This is not a strict requirement, but will go a long way toward keeping your locales easily maintainable.

In any locale file entry, you can reference another key in the locale file by using the syntax `!scope.to.key!`. For the sake of maintainability, I recommend restricting the use of this feature to small, highly-recycled fragments of static text. `I18n`'s built-in `%{value}` interpolation can be used for variable text.

### In Views

To access this text in views, two helpers are available, `text` and `html`. Both helpers take a lookup key, used to identify the desired piece of text, and an argument hash, which is forwarded to the `I18n.t` call.

`text` returns the requested text, with special values interpolated, and made html_safe (so HTML can be used here, when absolutely necessary).

`html` parses the requested text using Markdown, making it useful for rendering larger pieces of text involving multiple paragraphs, list items or links.

`html` automatically parses Markdown using [`SmartyPants`-style](http://daringfireball.net/projects/smartypants/) character conversions, so you can write plain text and have the proper typographical elements generated for you without having to explicitly insert HTML entities for common cases.

If you want to render a small fragment of Markdown without `p` tag wrappers, you can pass `inline: true` as an option to `html`.

`text` and `html` will escape all arguments passed to it in order to prevent XSS attacks. If you want to pass html content, you should ensure you mark it as .html_safe

Example: `text('welcome_user', username)` will escape html characters in username
```ruby
Welcome &lt;b&gt;Bob&lt;/b&gt;
```

Example: `text('welcome_user', username.html_safe)` will output html characters in username
```ruby
Welcome <b>Bob</b>
```

### In Controllers

The same helpers are available in controllers, with the translation scope based on the controller name rather than the view directory. This will typically be used for flash messages or alerts of some kind.

## Testing

Some shared `RSpec` contexts are available to allow the same locale abstractions for testing. You can include these contexts with:

```
require "text_helpers/contexts"
```

### Views

The view text helpers described above can be accessed in view specs by adding `view: true` to the spec metadata.

### Controllers

The controller text helpers described above can be accessed in controller specs by adding `controller: true` to your spec metadata.

### Temporary/Stub Localizations

`text_helpers/rspec.rb` contains some helpers for setting up a test localization
environment during your test runs. You can enable the helper methods by adding
the `:text_helpers` tag to the examples that require them.

To configure it, `require "text_helpers/rspec"` and configure the `before` and
`after` hooks appropriately:

```
require 'text_helpers/rspec'

RSpec.configure do |config|
  config.include TextHelpers::RSpec::TestHelpers, text_helpers: true

  config.before(:suite) do
    TextHelpers::RSpec.setup_spec_translations
  end

  config.after(:each, :text_helpers) do
    TextHelpers::RSpec.reset_spec_translations
  end
end
```

Temporary localizations can then be defined within your examples via the
`#set_translation` method, like so:

```
describe "with a translation set", :text_helpers do
  before do
    set_translation('models.user.attributes.name', 'Name')
  end

  it { ... }
end
```

## Configuration & Initialization

### Initialization

`TextHelpers` performs some setup during your application's initialization. Five initializers are installed:

#### `text_helpers.action_view.extend_base`

This initializer includes the `TextHelpers::Translation` module into `ActionView::Base` and adds an appropriate `#translation_scope` method.

#### `text_helpers.action_mailer.extend_base`

This initializer includes the `TextHelpers::Translation` module into `ActionMailer::Base` and adds an appropriate `#translation_scope` method.

#### `text_helpers.action_controller.extend_base`

This initializer includes the `TextHelpers::Translation` module into `ActionController::Base` and adds an appropriate `#translation_scope` method.

#### `text_helpers.i18n.add_load_paths`

This initializer updates the default I18n locale file load paths for your Rails application to recursively include files within directories and subdirectories. This enables a more hierarchical organization of your locale files.

#### `text_helpers.setup_exception_handling`

This initializer configures exception handling so that exceptions are raised if `config.text_helpers.raise_on_missing_translations` is set to `true`, which it is by default in the `test` or `development` environments.

### Configuration

#### `config.text_helpers.raise_on_missing_translations`

This configuration value defaults to `true` in `test` or `development` environments. If set to `false`, your own exception handling can be configured by setting `config.action_view.raise_on_missing_translations` and `I18n.exception_handler` as appropriate.
