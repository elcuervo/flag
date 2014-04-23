require "spec_helper"

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

      Then { Flag(:test).on?(1) == false }
      And  { Flag(:test).on?(2) == true }
      And  { Flag(:test).on?(3) == true }
    end
  end

  context "users" do
    context "enabled only for a user" do
      When { Flag(:test).on!(1) }

      Then { Flag(:test).on?(1) == true }
      And  { Flag(:test).on?(2) == false }
    end

    context "with non numeric users" do
      When { Flag(:test).on!("ImARandomUUID") }
      Then { Flag(:test).on?("ImARandomUUID") == true }
    end
  end

  context "keys" do
    Given(:feature) { Flag(:test_the_key) }
    Then { feature.key == "_flag:features:test_the_key" }
  end

  context "percentage" do
    Given { Flag(:test).on!("50%") }

    Then { Flag(:test).on?(1) == false }
    And  { Flag(:test).on?(2) == true }
    And  { Flag(:test).on?("49%") == false }
    And  { Flag(:test).on?("50%") == true }
  end

  context "get feature info" do
    Given { Flag(:test).on!("50%") }
    Given { Flag(:test).on!("25") }
    Given { Flag(:test).on!("UUID") }
    Given { Flag(:test).on!(:staff) }

    Then { Flag(:test).actived.is_a?(Hash) }
    And  { Flag(:test).actived[:percentage] == "50%" }
    And  { Flag(:test).actived[:users] == ["25", "UUID"] }
    And  { Flag(:test).actived[:groups] == [:staff] }
  end
end
