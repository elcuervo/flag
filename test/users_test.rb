require_relative "./spec_helper"

prepare do
  Flag.flush
end

scope "users" do
  test "enabled only for a user" do
    Flag(:test).on!(1)

    assert Flag(:test).on?(1) == true
    assert Flag(:test).on?(2) == false
  end

  test "using any kind of id" do
    Flag(:test).on!("ImARandomUUID")

    assert Flag(:test).on?("ImARandomUUID")
  end
end
