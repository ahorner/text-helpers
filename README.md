# TextHelpers

`TextHelpers` is a library intended to make working with static text in Rails 
projects as painless as possible.

Include it in your `Gemfile` with:

```
gem "text_helpers"
```

## Suggested Use

All static text should be placed in locale files, in a directory 
structure mirroring the app directory structure. The text for 
`app/views/some/_partial.html.haml` would go in 
`config/locales/views/some/partial.en.yml`, for example. This is not a strict
requirement, but will go a long way toward keeping your locales easily
maintainable.

If you're using this within a Rails project, you'll probably want to add the
following line to your application.rb to ensure that Rails loads any locale
files organized this way:

```ruby
config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
```

In any locale file entry, you can reference another key in the locale file by
using the syntax `!scope.to.key!`. For the sake of maintainability, the use of
this interpolation should be restricted to small fragments of highly-recycled 
static values. `I18n`'s built-in `%{value}` interpolation can be used for 
variable text.

### In Views

To access this text in views, two helpers are available, `text` and `html`.
Both helpers take a lookup key, used to identify the desired piece of text, 
and an argument hash, which is forwarded to the `I18n.t` call.

`text` returns the requested text, with special values interpolated, and made 
html_safe (so HTML can be used here, when absolutely necessary).

`html` parses the requested text using Markdown, making it useful for rendering
larger pieces of text involving multiple paragraphs, list items or links.

If you want to render a small fragment of Markdown without `p` tag wrappers,
you can pass `inline: true` as an option to `html`.

### In Controllers

The same helpers are available in controllers, with the translation scope based
on the controller name rather than the view directory. This will typically be
used for flash messages or alerts of some kind.

## Testing

Some shared `RSpec` contexts are available to allow the same locale 
abstractions for testing. You can include these contexts with:

```
require "text_helpers/contexts"
```

### Views

The view text helpers described above can be accessed in view
specs by adding `view: true` to the spec metadata.

### Controllers

The controller text helpers described above can be accessed in controller
specs by adding `controller: true` to your spec metadata.
