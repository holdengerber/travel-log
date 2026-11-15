require "test_helper"

class EntriesPageTest < ActionDispatch::IntegrationTest
  test "The place's page has a link to a form for a new entry." do
    place = Place.new
    place["name"] = "Lisbon"
    place.save

    get("/places/#{place["id"]}")

    assert_select("a[href=?]", "/entries/new?place_id=#{place["id"]}")
  end

  test "The new entry form has boxes for the title, the description and the day it happened, and a button." do
    place = Place.new
    place["name"] = "Lisbon"
    place.save

    get("/entries/new?place_id=#{place["id"]}")

    assert_response(:success)
    assert_select("form[action=?][method=?]", "/entries", "post") do
      assert_select("input[name=?]", "title")
      assert_select("input[name=?]", "description")
      assert_select("input[name=?][type=?]", "occurred_on", "date")
      assert_select("input[name=?][value=?]", "place_id", place["id"].to_s)
      assert_select("button")
    end
  end

  test "Submitting the form creates an entry for that place with the title, description and date that were entered." do
    place = Place.new
    place["name"] = "Lisbon"
    place.save

    post("/entries", :params => { "title" => "Grilled sardines in Alfama", "description" => "Six of them.", "occurred_on" => "2026-03-15", "place_id" => place["id"] })

    assert_equal(1, Entry.count)
    entry = Entry.first
    assert_equal("Grilled sardines in Alfama", entry["title"])
    assert_equal("Six of them.", entry["description"])
    assert_equal(Date.new(2026, 3, 15), entry["occurred_on"])
    assert_equal(place["id"], entry["place_id"])
  end

  test "After submitting, the user lands on the place's page and sees the new entry there." do
    place = Place.new
    place["name"] = "Lisbon"
    place.save

    post("/entries", :params => { "title" => "Grilled sardines in Alfama", "description" => "Six of them.", "occurred_on" => "2026-03-15", "place_id" => place["id"] })

    assert_redirected_to("/places/#{place["id"]}")
    follow_redirect!
    assert_select("li", /Grilled sardines in Alfama/)
  end
end
