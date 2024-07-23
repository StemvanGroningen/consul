require "rails_helper"

describe "Home" do
  scenario "cards are first sorted by 'order' field, then by 'created_at' when order is equal" do
    create(:widget_card, title: "Card one", order: 1)
    create(:widget_card, title: "Card two", order: 3)
    create(:widget_card, title: "Card three", order: 2)
    create(:widget_card, title: "Card four", order: 3)

    visit root_path

    within(".cards-container") do
      expect("Card one").to appear_before("Card three")
      expect("Card three").to appear_before("Card two")
      expect("Card two").to appear_before("Card four")
    end
  end
end
