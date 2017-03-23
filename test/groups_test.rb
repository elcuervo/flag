require_relative "./spec_helper"

prepare do
  Flag.flush
end

scope "groups" do
  setup do
    Flag.group[:staff] = lambda { |id| id > 1 }
  end

  test "adding groups" do
    assert_equal [:staff], Flag.groups
  end

  test "testing if feature is activated for a group" do
    Flag(:test).on!(:staff)

    assert Flag(:test).on?(:staff)
  end

  test "trying to check for an empty group" do
    Flag(:test).on!(:bogus)

    assert_equal false, Flag(:test).on?(1)
  end

  test "testing if a user beloging to a group get stuff activated" do
    Flag(:test).on!(:staff)

    assert Flag(:test).on?(1) == false
    assert Flag(:test).on?(2) == true
    assert Flag(:test).on?(3) == true
  end
end
