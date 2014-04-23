require "spec_helper"
require "byebug"

describe Flag do
  after { Flag.flush }

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

  context "groups" do
    Given do
      Flag.group[:staff] = lambda { |id| id > 1 }
    end

    context "adding groups" do
      When(:groups) { Flag.groups }
      Then { groups == [:staff] }
    end

    context "testing if feature is actived for a group" do
      Given { Flag(:test).on!(:staff) }
      When(:feature) { Flag(:test).on?(:staff) }
      Then { feature == true }
    end

    context "testing if a user beloging to a group get stuff activated" do
      Given { Flag(:test).on!(:staff) }

      Then  { Flag(:test).on?(1) == false }
      And   { Flag(:test).on?(2) == true }
      And   { Flag(:test).on?(3) == true }
    end
  end

  context "users" do
    context "enabled only for a user" do
      When { Flag(:test).on!(1) }

      Then { Flag(:test).on?(1) == true }
      And  { Flag(:test).on?(2) == false }
    end
  end
end
