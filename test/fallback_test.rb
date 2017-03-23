require_relative "./spec_helper"

scope "fallback" do
  setup do
    Flag.store = Redic.new("redis://localhost:6380/23")
  end

  scope "normal mode" do
    test "fail when Redis is gone" do
      Flag.quiet = false

      assert Flag.quiet? == false
      assert_raise(Flag::RedisGoneError) do
        Flag(:fallback).on!
      end
    end
  end

  scope "quiet mode" do
    setup do
      Flag.quiet!
    end

    test "do not fail when Redis is gone" do
      assert Flag.quiet? == true

      Flag(:fallback).on!

      assert Flag(:fallback).on? == false
    end
  end
end
