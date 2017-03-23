require_relative "./spec_helper"

prepare do
  Flag.flush
end

scope "fallback" do
  setup do
    Flag.store = Redic.new("redis://localhost:6380/23")
    Flag.quiet!
  end

  test do
    Flag(:fallback).on!

    assert Flag(:fallback).on? == false
  end
end
