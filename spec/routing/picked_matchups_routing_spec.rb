require "spec_helper"

describe PickedMatchupsController do
  describe "routing" do

    it "routes to #index" do
      get("/picked_matchups").should route_to("picked_matchups#index")
    end

    it "routes to #new" do
      get("/picked_matchups/new").should route_to("picked_matchups#new")
    end

    it "routes to #show" do
      get("/picked_matchups/1").should route_to("picked_matchups#show", :id => "1")
    end

    it "routes to #edit" do
      get("/picked_matchups/1/edit").should route_to("picked_matchups#edit", :id => "1")
    end

    it "routes to #create" do
      post("/picked_matchups").should route_to("picked_matchups#create")
    end

    it "routes to #update" do
      put("/picked_matchups/1").should route_to("picked_matchups#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/picked_matchups/1").should route_to("picked_matchups#destroy", :id => "1")
    end

  end
end
