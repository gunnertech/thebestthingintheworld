require "spec_helper"

describe AssignedThingsController do
  describe "routing" do

    it "routes to #index" do
      get("/assigned_things").should route_to("assigned_things#index")
    end

    it "routes to #new" do
      get("/assigned_things/new").should route_to("assigned_things#new")
    end

    it "routes to #show" do
      get("/assigned_things/1").should route_to("assigned_things#show", :id => "1")
    end

    it "routes to #edit" do
      get("/assigned_things/1/edit").should route_to("assigned_things#edit", :id => "1")
    end

    it "routes to #create" do
      post("/assigned_things").should route_to("assigned_things#create")
    end

    it "routes to #update" do
      put("/assigned_things/1").should route_to("assigned_things#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/assigned_things/1").should route_to("assigned_things#destroy", :id => "1")
    end

  end
end
