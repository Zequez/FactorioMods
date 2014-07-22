require 'base64'

module Sass::Script::Functions
  def base64_encode(string)
    assert_type string, :String
    Sass::Script::String.new(Base64.encode64(string.value))
  end
  declare :base64Encode, :args => [:string]
end