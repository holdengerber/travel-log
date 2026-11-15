class PlacesController < ApplicationController
  def index
    @places = Place.order({ "name" => "asc" })

    render({ :template => "places/index" })
  end

  def new
    render({ :template => "places/new" })
  end

  def create
    place = Place.new
    place["name"] = params["name"]
    place.save

    redirect_to("/places")
  end
end
