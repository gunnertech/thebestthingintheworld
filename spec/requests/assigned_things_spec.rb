require 'spec_helper'

describe "AssignedThings" do
  describe "GET /assigned_things" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get assigned_things_path
      response.status.should be(200)
    end
  end
end
