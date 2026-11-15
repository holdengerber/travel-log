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

  test "The place's page shows the place's name." do
    place = Place.new
    place["name"] = "Lisbon"
    place.save

    get("/places/#{place["id"]}")

    assert_response(:success)
    assert_select("h1", "Lisbon")
  end

  test "The place's page lists each of its entries with its title and the day it happened." do
    place = Place.new
    place["name"] = "Lisbon"
    place.save
    sardines = Entry.new
    sardines["title"] = "Grilled sardines in Alfama"
    sardines["description"] = "Six of them."
    sardines["occurred_on"] = "2026-03-15"
    sardines["place_id"] = place["id"]
    sardines.save
    tram = Entry.new
    tram["title"] = "Rode tram 28"
    tram["description"] = "Up the hill to the castle."
    tram["occurred_on"] = "2026-03-16"
    tram["place_id"] = place["id"]
    tram.save

    get("/places/#{place["id"]}")

    assert_select("li", { :count => 2 })
    assert_select("li", /Grilled sardines in Alfama.*2026-03-15/)
    assert_select("li", /Rode tram 28.*2026-03-16/)
  end

  test "The place's page does not show entries from other places." do
    lisbon = Place.new
    lisbon["name"] = "Lisbon"
    lisbon.save
    kyoto = Place.new
    kyoto["name"] = "Kyoto"
    kyoto.save
    sardines = Entry.new
    sardines["title"] = "Grilled sardines in Alfama"
    sardines["description"] = "Six of them."
    sardines["occurred_on"] = "2026-03-15"
    sardines["place_id"] = lisbon["id"]
    sardines.save
    temple = Entry.new
    temple["title"] = "Visited Kinkaku-ji"
    temple["description"] = "The golden pavilion."
    temple["occurred_on"] = "2026-04-02"
    temple["place_id"] = kyoto["id"]
    temple.save

    get("/places/#{lisbon["id"]}")

    assert_select("li", /Grilled sardines in Alfama/)
    assert_select("li", { :text => /Visited Kinkaku-ji/, :count => 0 })
  end

  test "The place's page has a link back to the places page." do
    place = Place.new
    place["name"] = "Lisbon"
    place.save

    get("/places/#{place["id"]}")

    assert_select("a[href=?]", "/places")
  end
end
