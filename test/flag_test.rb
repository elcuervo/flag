require "spec_helper"
require "byebug"

describe "Flag" do
  context "features" do

    context "empty" do
      Given(:features) { Flag.keys }
      Then { features == [] }
    end

    context "having one" do
      Given { Flag(:test).on! }
      Then  { Flag.keys == [:test] }
    end

    context "turning them off" do
      Given { Flag(:test).on! }
      When  { Flag(:test).off! }
      When  { Flag(:test2).on! }

      Then  { Flag.keys == [:test2] }
      And   { Flag.features.keys == [:test, :test2] }
    end

  end
end
