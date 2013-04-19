require "spec_helper"

describe MatchupsController do
  describe "routing" do

    it "routes to #index" do
      get("/matchups").should route_to("matchups#index")
    end

    it "routes to #new" do
      get("/matchups/new").should route_to("matchups#new")
    end

    it "routes to #show" do
      get("/matchups/1").should route_to("matchups#show", :id => "1")
    end

    it "routes to #edit" do
      get("/matchups/1/edit").should route_to("matchups#edit", :id => "1")
    end

    it "routes to #create" do
      post("/matchups").should route_to("matchups#create")
    end

    it "routes to #update" do
      put("/matchups/1").should route_to("matchups#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/matchups/1").should route_to("matchups#destroy", :id => "1")
    end

  end
end
