require 'spec_helper'

describe "PickedMatchups" do
  describe "GET /picked_matchups" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get picked_matchups_path
      response.status.should be(200)
    end
  end
end
