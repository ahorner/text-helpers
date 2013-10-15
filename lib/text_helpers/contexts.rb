shared_context "a view spec", view: true do
  include TextHelpers::Translation

  def translation_scope
    matcher = /(?<path>.*)\/_?(?<view>[^\/.]+)(?<extension>\.html\.haml)?/
    info = matcher.match(example.metadata[:full_description])

    if info
      path = info[:path].gsub('/', '.')
      "views.#{path}.#{info[:view]}"
    else
      "views.#{params[:controller]}.#{params[:action]}"
    end
  end
end

shared_context "a controller spec", controller: true do
  include TextHelpers::Translation

  def translation_scope
    controller_name = described_class.name.sub(/Controller\z/, '').underscore
    "controllers.#{controller_name}"
  end
end
