require "rails_helper"

describe "Custom Pages" do
  scenario "Don't show subtitle if its blank" do
    custom_page = create(:site_customization_page, :published,
      slug: "slug-without-subtitle",
      title_en: "Custom page",
      subtitle_en: "",
      content_en: "Text for new custom page",
      print_content_flag: false
    )

    visit custom_page.url

    within ".wrapper" do
      expect(page).to have_title("Custom page")
      expect(page).to have_selector("h1", text: "Custom page")
      expect(page).to have_content("Text for new custom page")
      expect(page).not_to have_selector("h2")
      expect(page).not_to have_content("Print this info")
    end
  end
end
