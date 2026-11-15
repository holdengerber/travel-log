class PlacesController < ApplicationController
  def index
    @places = Place.order({ "name" => "asc" })

    render({ :template => "places/index" })
  end
end
