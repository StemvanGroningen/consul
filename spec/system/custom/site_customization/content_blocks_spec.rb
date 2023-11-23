require "rails_helper"

describe "Custom content blocks" do
  scenario "footer" do
    create(:site_customization_content_block, name: "footer", locale: "en",
                                              body: "content for footer")
    create(:site_customization_content_block, name: "footer", locale: "es",
                                              body: "contenido para footer")

    visit "/?locale=en"

    expect(page).not_to have_content "content for footer"
    expect(page).not_to have_content "contenido para footer"

    visit "/?locale=es"

    expect(page).not_to have_content "contenido para footer"
    expect(page).not_to have_content "content for footer"
  end
end
