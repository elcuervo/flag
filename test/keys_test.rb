require_relative "./spec_helper"

prepare do
  Flag.flush
end

scope "keys" do
  test "uses the correct namespace" do
    assert_equal  "_flag:features:test_the_key", Flag(:test_the_key).key
  end
end
