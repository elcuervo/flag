require "spec_helper"

describe "Flag" do
  context "features" do

    context "empty" do
      Given(:features) { Flag.keys }
      Then { features == [] }
    end

    context "having one" do
      Given { Flag(:test).on! }
      Then { Flag.keys == [:test] }
    end

    context "turning them off" do
      Given { Flag(:test).on! }
      When  { Flag(:test).off! }
      Then  { Flag.keys == [] }
    end

  end
end
