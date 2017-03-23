require_relative "./spec_helper"

prepare do
  Flag.flush
end

scope "percentage" do
  test "only half" do
    Flag(:test).on!("50%")

    assert Flag(:test).on?(1) == false
    assert Flag(:test).on?(2) == true
    assert Flag(:test).on?("49%") == false
    assert Flag(:test).on?("50%") == true
  end
end
