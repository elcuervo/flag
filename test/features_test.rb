require_relative "./spec_helper"

prepare do
  Flag.flush
end

scope "features" do
  test "empty" do
    assert_equal [], Flag.enabled
  end

  test "having one" do
    Flag(:test).on!
    assert_equal [:test], Flag.enabled
  end

  test "turning them off" do
    Flag(:test).on!
    Flag(:test).off!
    Flag(:test2).on!

    assert_equal [:test2], Flag.enabled
    assert_equal [:test, :test2], Flag.features.keys
  end

  test "get feature info" do
    Flag(:test).on!("50%")
    Flag(:test).on!("25")
    Flag(:test).on!("UUID")
    Flag(:test).on!(:staff)

    assert Flag(:test).activated.is_a?(Hash)
    assert Flag(:test).activated[:percentage] == 50
    assert Flag(:test).activated[:users].size == 2
    assert Flag(:test).activated[:users].include?("25")
    assert Flag(:test).activated[:users].include?("UUID")
    assert Flag(:test).activated[:groups] == [:staff]
  end
end
