require "test_helper"

class PlacesPageTest < ActionDispatch::IntegrationTest
  test "The places page lists the name of every place." do
    lisbon = Place.new
    lisbon["name"] = "Lisbon"
    lisbon.save
    kyoto = Place.new
    kyoto["name"] = "Kyoto"
    kyoto.save

    get("/places")

    assert_response(:success)
    assert_select("li", { :count => 2 })
    assert_select("li", "Lisbon")
    assert_select("li", "Kyoto")
  end

  test "Each place's name links to that place's page." do
    place = Place.new
    place["name"] = "Lisbon"
    place.save

    get("/places")

    assert_select("a[href=?]", "/places/#{place["id"]}", { :text => "Lisbon" })
  end

  test "When there are no places, the places page says there are no places yet." do
    get("/places")

    assert_response(:success)
    assert_select("li", { :count => 0 })
    assert_select("p", "There are no places yet.")
  end
end
