require_relative "../../test_helper"

describe TextHelpers do

  it "defines a version" do
    TextHelpers::VERSION.wont_be_nil
  end
end
