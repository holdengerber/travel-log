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

  test "The new place page has a form with a box for the place's name and a button." do
    get("/places/new")

    assert_response(:success)
    assert_select("form[action=?][method=?]", "/places", "post") do
      assert_select("input[name=?]", "name")
      assert_select("button")
    end
  end

  test "Submitting the form creates a place with the name that was entered." do
    post("/places", { :params => { "name" => "Lisbon" } })

    assert_equal(1, Place.count)
    assert_equal("Lisbon", Place.first["name"])
  end

  test "After submitting, the user lands on the places page and sees the new place there." do
    post("/places", { :params => { "name" => "Lisbon" } })

    assert_redirected_to("/places")
    follow_redirect!
    assert_select("li", "Lisbon")
  end

  test "The places page has a link to the new place page." do
    get("/places")

    assert_select("a[href=?]", "/places/new")
  end
end
