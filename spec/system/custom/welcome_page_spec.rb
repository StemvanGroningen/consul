require "rails_helper"

describe "Welcome page" do
  context "Feeds" do
    scenario "Show message if there are no items" do
      visit root_path

      within "#feed_proposals" do
        expect(page).to have_content "There are no proposals right now"
      end

      within "#feed_debates" do
        expect(page).to have_content "There are no debates right now"
      end

      within "#feed_budgets" do
        expect(page).to have_content "There are no budgets right now"
      end

      within "#feed_processes" do
        expect(page).to have_content "There are no open processes right now"
      end
    end

    scenario "Show budgets info" do
      budget = create(:budget, :accepting)

      visit root_path

      within "#feed_budgets" do
        expect(page).to have_content budget.name
        expect(page).to have_content budget.formatted_total_headings_price
        expect(page).to have_content budget.current_phase.name
        expect(page).to have_content "#{budget.current_enabled_phase_number}/#{budget.enabled_phases_amount}"
        expect(page).to have_content budget.current_phase.starts_at.to_date.to_s
        expect(page).to have_content (budget.current_phase.ends_at.to_date - 1.day).to_s
        expect(page).to have_content budget.description
        expect(page).to have_content "See this budget", count: 1
        expect(page).to have_link href: budget_path(budget)
      end
    end
  end

  scenario "Show all budgets except drafting, reviewing and finished" do
    create(:widget_feed, kind: "budgets", limit: 10)
    create(:budget, :drafting, name: "Budget draft")

    phase = %w[accepting selecting reviewing publishing_prices balloting reviewing_ballots valuating finished]

    phase.each_with_index do |phase_name, index|
      create(:budget, phase: phase_name, name: "Budget #{index} #{phase_name}")
    end

    visit root_path

    within "#feed_budgets" do
      expect(page).to have_content "Budget 0 accepting"
      expect(page).to have_content "Budget 1 selecting"
      expect(page).to have_content "Budget 2 reviewing"
      expect(page).to have_content "Budget 3 publishing_prices"
      expect(page).to have_content "Budget 4 balloting"
      expect(page).to have_content "Budget 5 reviewing_ballots"
      expect(page).not_to have_content "Budget draft"
      expect(page).not_to have_content "Budget 6 valuating"
      expect(page).not_to have_content "Budget 7 finished"
      expect(page).to have_css ".budget", count: 6
    end
  end

  scenario "Show three steps section only if feature is enabled" do
    Setting["feature.welcome_steps"] = false

    visit root_path

    expect(page).not_to have_selector "#home_page_steps"

    Setting["feature.welcome_steps"] = true

    visit root_path

    within "#home_page_steps" do
      expect(page).to have_content "1"
      expect(page).to have_content "Sign-up"
      expect(page).to have_content "Short text describing some of the data that is expected to be "\
                                   "asked when making an account."
      expect(page).to have_link "Make an account in 5 minutes"
      expect(page).to have_content "2"
      expect(page).to have_content "Decide"
      expect(page).to have_content "Share your ideas and vote on the changes you want to see in the city."
      expect(page).to have_link "See what's happening around the city right now"
      expect(page).to have_content "3"
      expect(page).to have_content "Share"
      expect(page).to have_content "Keep up with the ideas that matter to you the most, and share them "\
                                   "through social media."
      expect(page).to have_link "Another optional call to action"
    end
  end

  scenario "Show footer background image only if feature is enabled" do
    Setting["feature.background_image_footer"] = false

    visit root_path

    expect(page).not_to have_selector "#bg_footer"

    Setting["feature.background_image_footer"] = true

    visit root_path

    within "#bg_footer" do
      expect(page).to have_css("img[alt=\"\"]")
    end
  end
end
