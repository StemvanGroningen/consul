require "rails_helper"

describe "Admin custom information texts", :admin do
  scenario "page is correctly loaded" do
    visit admin_site_customization_information_texts_path

    visit admin_site_customization_information_texts_path(tab: "basic")
    expect(page).to have_content "Help about debates"
    expect(page).to have_content "Help about proposals"
    expect(page).to have_content "Help about voting"
    expect(page).to have_content "Help about collaborative legislation"
    expect(page).to have_content "Help with participatory budgets"

    visit admin_site_customization_information_texts_path(tab: "debates")
    expect(page).to have_content "Help about debates"

    visit admin_site_customization_information_texts_path(tab: "budgets")
    expect(page).to have_content "Help with participatory budgets"

    visit admin_site_customization_information_texts_path(tab: "legislation")
    expect(page).to have_content "Help about collaborative legislation"

    visit admin_site_customization_information_texts_path(tab: "proposals")
    expect(page).to have_content "Create proposal"

    visit admin_site_customization_information_texts_path(tab: "polls")
    expect(page).to have_content "Results"

    visit admin_site_customization_information_texts_path(tab: "layouts")
    expect(page).to have_content "Accessibility"

    visit admin_site_customization_information_texts_path(tab: "mailers")
    expect(page).to have_content "Confirm your email"

    visit admin_site_customization_information_texts_path(tab: "management")
    expect(page).to have_content "This user account is already verified."

    visit admin_site_customization_information_texts_path(tab: "welcome")
    expect(page).to have_content "See all debates"
  end

  scenario "check that tabs are highlight when click it" do
    visit admin_site_customization_information_texts_path

    within("#information-texts-tabs") { click_link "Proposals" }
    expect(find("a[href=\"/admin/site_customization/information_texts?tab=proposals\"].is-active"))
          .to have_content "Proposals"
  end

  context "Globalization" do
    scenario "Add a translation" do
      key = "debates.index.section_footer.title"

      visit admin_site_customization_information_texts_path

      select "Français", from: :add_language
      fill_in "contents[content_#{key}]values[value_fr]", with: "Aide personalise sur les débats"

      click_button "Save"

      expect(page).to have_content "Translation updated successfully"

      visit admin_site_customization_information_texts_path
      select "Français", from: :select_language

      expect(page).to have_content "Aide personalise sur les débats"
      expect(page).not_to have_content "Aide sur les débats"
    end

    scenario "Update a translation" do
      key = "proposals.show.share"
      create(:i18n_content, key: key, value_fr: "Partager la proposition")

      visit admin_site_customization_information_texts_path(tab: "proposals")

      select "Français", from: :select_language
      fill_in "contents_content_#{key}values_value_fr", with: "Partager personalise"

      click_button "Save"
      expect(page).to have_content "Translation updated successfully"

      visit admin_site_customization_information_texts_path(tab: "proposals")
      select "Français", from: :select_language

      expect(page).to have_content "Partager personalise"
      expect(page).not_to have_content "Partager la proposition"
    end

    scenario "Remove a translation" do
      featured = create(:i18n_content, key: "debates.index.featured_debates",
                                       value_en: "Custom featured",
                                       value_es: "Destacar personalizado")

      page_title = create(:i18n_content, key: "debates.new.start_new",
                                          value_en: "Start a new debate",
                                          value_es: "Empezar un debate")

      visit admin_site_customization_information_texts_path(tab: "debates")

      select "Español", from: :select_language
      click_link "Remove language"
      click_button "Save"

      expect(page).not_to have_link "Español"

      visit admin_site_customization_information_texts_path(tab: "debates")
      select "English", from: :select_language

      expect(page).to have_content "Start a new debate"
      expect(page).to have_content "Custom featured"

      featured.reload
      page_title.reload

      expect(page_title.value_es).to be nil
      expect(featured.value_es).to be nil
      expect(page_title.value_en).to eq "Start a new debate"
      expect(featured.value_en).to eq "Custom featured"
    end
  end
end
