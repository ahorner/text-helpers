RSpec.shared_context "a controller spec", controller: true do
  include TextHelpers::Translation

  def translation_scope
    controller_name = described_class.name.sub(/Controller\z/, '').underscore
    "controllers.#{controller_name}"
  end
end

RSpec.shared_context "a mailer spec", mailer: true do
  include TextHelpers::Translation

  def translation_scope
    mailer_name = described_class.name.sub(/Mailer\z/, '').underscore
    "mailers.#{mailer_name}"
  end
end

RSpec.shared_context "a view spec", view: true do
  include TextHelpers::Translation

  def translation_scope
    matcher = /(?<path>.*)\/_?(?<view>[^\/.]+)(?<extension>\.html\.haml)?/
    info = matcher.match(_default_file_to_render)
    path = info[:path].gsub('/', '.')
    "views.#{path}.#{info[:view]}"
  end
end
