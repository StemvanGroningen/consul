require "rails_helper"

describe "Budgets" do
  let(:budget)             { create(:budget) }
  let(:level_two_user)     { create(:user, :level_two) }
  let(:allowed_phase_list) { ["balloting", "reviewing_ballots", "finished"] }

  context "Load" do
    before { budget.update(slug: "budget_slug") }

    scenario "finds budget by slug" do
      visit budget_path("budget_slug")

      expect(page).to have_content budget.name
    end
  end

  context "Menu" do
    scenario "Show single link if there is only one open budget" do
      open_budget = create(:budget)
      finished_budget = create(:budget, :finished)

      visit root_path

      within("#navigation_bar") do
        expect(page).to have_link("Participatory budgeting", href: budgets_path)
        expect(page).not_to have_link(open_budget.name, href: budget_path(open_budget))
        expect(page).not_to have_link(finished_budget.name, href: budget_path(finished_budget))
      end
    end

    scenario "Do not show drafting budgets for non admin users" do
      drafting_budget = create(:budget, :drafting)
      published_budget = create(:budget)

      visit root_path

      within("#navigation_bar") do
        expect(page).to have_link("Participatory budgeting", href: budgets_path)
        expect(page).not_to have_link(drafting_budget.name, href: budget_path(drafting_budget))
        expect(page).not_to have_link(published_budget.name, href: budget_path(published_budget))
      end

      user = create(:user)
      login_as(user)

      visit root_path

      within("#navigation_bar") do
        expect(page).to have_link("Participatory budgeting", href: budgets_path)
        expect(page).not_to have_link(drafting_budget.name, href: budget_path(drafting_budget))
        expect(page).not_to have_link(published_budget.name, href: budget_path(published_budget))
      end

      admin = create(:administrator).user
      login_as(admin)
      visit root_path

      within("#navigation_bar") do
        expect(page).to have_link(drafting_budget.name, href: budget_path(drafting_budget), visible: :hidden)
        expect(page).to have_link(published_budget.name, href: budget_path(published_budget), visible: :hidden)
      end
    end

    scenario "Show budget links in the main menu" do
      admin = create(:administrator).user
      budget_1 = create(:budget)
      budget_2 = create(:budget)
      budget_3 = create(:budget, :drafting)
      budget_4 = create(:budget, :finished)

      visit root_path

      within("#navigation_bar") do
        expect(page).to have_link("Participatory budgeting", href: "#")
        expect(page).to have_link(budget_1.name, href: budget_path(budget_1), visible: :hidden)
        expect(page).to have_link(budget_2.name, href: budget_path(budget_2), visible: :hidden)
        expect(page).not_to have_link(budget_3.name, href: budget_path(budget_3), visible: :hidden)
        expect(page).not_to have_link(budget_4.name, href: budget_path(budget_4), visible: :hidden)
      end

      login_as(admin)
      visit root_path

      within("#navigation_bar") do
        expect(page).to have_link("Participatory budgeting", href: "#")
        expect(page).to have_link(budget_1.name, href: budget_path(budget_1), visible: :hidden)
        expect(page).to have_link(budget_2.name, href: budget_path(budget_2), visible: :hidden)
        expect(page).to have_link(budget_3.name, href: budget_path(budget_3), visible: :hidden)
        expect(page).not_to have_link(budget_4.name, href: budget_path(budget_4), visible: :hidden)
      end
    end
  end

  describe "Index" do
    describe "Normal index" do
      let!(:group1)   { create(:budget_group, budget: budget) }
      let!(:group2)   { create(:budget_group, budget: budget) }
      let!(:heading1) { create(:budget_heading, group: group1) }
      let!(:heading2) { create(:budget_heading, group: group2) }

      scenario "Show normal index with links in informing phase" do
        budget.update!(phase: "informing")

        visit budgets_path

        within(".budget-header") do
          expect(page).to have_content(budget.name)
          expect(page).to have_link("Help with participatory budgets")
        end

        within(".budget-subheader") do
          expect(page).to have_content "CURRENT PHASE"
          expect(page).to have_content "Information"
        end
      end

      scenario "Show normal index with links publishing prices" do
        budget.update!(phase: "publishing_prices")

        visit budgets_path

        within(".budget-subheader") do
          expect(page).to have_content("Publishing projects prices")
        end

        within("#budget_info") do
          expect(page).to have_content(group1.name)
          expect(page).to have_content(group2.name)
          expect(page).to have_content(heading1.name)
          expect(page).to have_content(budget.formatted_heading_price(heading1))
          expect(page).to have_content(heading2.name)
          expect(page).to have_content(budget.formatted_heading_price(heading2))
        end

        expect(page).not_to have_content("#finished_budgets")
      end
    end

    scenario "Show custom phase name on subheader" do
      budget.update!(phase: "informing")
      budget.phases.informing.update!(name: "Custom name for informing phase")

      visit budgets_path

      within(".budget-subheader") do
        expect(page).to have_content("CURRENT PHASE")
        expect(page).to have_content("Custom name for informing phase")
        expect(page).not_to have_content("Information")
      end
    end

    scenario "Show finished budgets list" do
      finished_budget_1 = create(:budget, :finished)
      finished_budget_2 = create(:budget, :finished)
      drafting_budget = create(:budget, :drafting)
      visit budgets_path

      within("#finished_budgets") do
        expect(page).to     have_content(finished_budget_1.name)
        expect(page).to     have_content(finished_budget_2.name)
        expect(page).not_to have_content(budget.name)
        expect(page).not_to have_content(drafting_budget.name)
      end
    end

    xscenario "Show headings ordered by name" do
      group = create(:budget_group, budget: budget)
      last_heading = create(:budget_heading, group: group, name: "BBB")
      first_heading = create(:budget_heading, group: group, name: "AAA")

      visit budgets_path

      expect(first_heading.name).to appear_before(last_heading.name)
    end

    xscenario "Show groups and headings for missing translations" do
      group1 = create(:budget_group, budget: budget)
      group2 = create(:budget_group, budget: budget)

      heading1 = create(:budget_heading, group: group1, price: 1_000_000)
      heading2 = create(:budget_heading, group: group2, price: 2_000_000)

      visit budgets_path locale: :es

      within("#budget_info") do
        expect(page).to have_content group1.name
        expect(page).to have_content group2.name
        expect(page).to have_content heading1.name
        expect(page).to have_content "1.000.000 €"
        expect(page).to have_content heading2.name
        expect(page).to have_content "2.000.000 €"
      end
    end

    scenario "Show informing index without links" do
      budget.update!(phase: "informing")
      heading = create(:budget_heading, budget: budget)

      visit budgets_path

      within("#budget_info") do
        expect(page).not_to have_link "#{heading.name} €1,000,000", normalize_ws: true
        expect(page).to have_content "#{heading.name} €1,000,000", normalize_ws: true

        expect(page).not_to have_link("List of all investment projects")
        expect(page).not_to have_link("List of all unfeasible investment projects")
        expect(page).not_to have_link("List of all investment projects not selected for balloting")

        expect(page).not_to have_css("div.map")
      end
    end

    scenario "Show finished index without heading links" do
      Setting["feature.map"] = true
      budget.update!(phase: "finished")
      heading = create(:budget_heading, budget: budget)

      visit budgets_path

      within("#budget_info") do
        expect(page).not_to have_link heading.name
        expect(page).to have_content "#{heading.name}\n€1,000,000"

        expect(page).to have_css("div.map")
      end
    end

    scenario "Hide money on single heading budget" do
      budget = create(:budget, :finished, :hide_money)
      heading = create(:budget_heading, budget: budget)

      visit budgets_path

      within("#budget_info") do
        expect(page).to have_content heading.name
        expect(page).not_to have_content "€"
      end
    end

    scenario "Hide money on multiple headings budget" do
      budget = create(:budget, :finished, :hide_money)
      heading1 = create(:budget_heading, budget: budget)
      heading2 = create(:budget_heading, budget: budget)
      heading3 = create(:budget_heading, budget: budget)

      visit budgets_path

      within("#budget_info") do
        expect(page).to have_content heading1.name
        expect(page).to have_content heading2.name
        expect(page).to have_content heading3.name
        expect(page).not_to have_content "€"
      end
    end

    scenario "No budgets" do
      Budget.destroy_all

      visit budgets_path

      expect(page).to have_content "There are no budgets"
    end

    scenario "Show heading for budget with single heading" do
      group = create(:budget_group, budget: budget, name: "Single group")
      create(:budget_heading, group: group, name: "New heading", price: 10_000)

      visit budgets_path

      expect(page).not_to have_content "Single group"

      within ".single-heading" do
        expect(page).to have_content "New heading"
        expect(page).to have_content "€10,000"
      end
    end

    scenario "Show group and headings for budget with multiple headings" do
      group = create(:budget_group, budget: budget, name: "New group")
      create(:budget_heading, group: group, name: "New heading", price: 10_000)
      create(:budget_heading, group: group, name: "Other new heading", price: 30_000)

      visit budgets_path

      within("#groups_and_headings") do
        expect(page).to have_content "New group"
        expect(page).to have_content "New heading"
        expect(page).to have_content "€10,000"
        expect(page).to have_content "Other new heading"
        expect(page).to have_content "€30,000"
      end
    end
  end

  scenario "Index shows only published phases" do
    budget.update!(phase: :finished)
    phases = budget.phases

    phases.informing.update!(starts_at: "30-12-2017", ends_at: "01-01-2018", enabled: true,
                             description: "Description of informing phase",
                             name: "Custom name for informing phase")

    phases.accepting.update!(starts_at: "01-01-2018", ends_at: "11-01-2018", enabled: true,
                             description: "Description of accepting phase",
                             name: "Custom name for accepting phase")

    phases.reviewing.update!(starts_at: "11-01-2018", ends_at: "21-01-2018", enabled: false,
                             description: "Description of reviewing phase")

    phases.selecting.update!(starts_at: "21-01-2018", ends_at: "01-02-2018", enabled: true,
                             description: "Description of selecting phase",
                             name: "Custom name for selecting phase")

    phases.valuating.update!(starts_at: "10-02-2018", ends_at: "21-02-2018", enabled: false,
                             description: "Description of valuating phase")

    phases.publishing_prices.update!(starts_at: "21-02-2018", ends_at: "02-03-2018", enabled: false,
                                     description: "Description of publishing prices phase")

    phases.balloting.update!(starts_at: "02-03-2018", ends_at: "11-03-2018", enabled: true,
                             description: "Description of balloting phase")

    phases.reviewing_ballots.update!(starts_at: "11-03-2018", ends_at: "21-03-2018", enabled: false,
                                     description: "Description of reviewing ballots phase")

    phases.finished.update!(starts_at: "21-03-2018", ends_at: "30-03-2018", enabled: true,
                            description: "Description of finished phase")

    visit budgets_path

    expect(page).not_to have_link "Reviewing projects"
    expect(page).not_to have_link "Valuating projects"
    expect(page).not_to have_link "Publishing projects prices"
    expect(page).not_to have_link "Reviewing voting"

    click_link "Custom name for informing phase"

    expect(page).to have_content "Description of informing phase"
    expect(page).to have_content "December 30, 2017 - December 31, 2017"

    click_link "Custom name for accepting phase"

    within("#phase-2-custom-name-for-accepting-phase") do
      expect(page).to have_link "Previous phase", href: "#phase-1-custom-name-for-informing-phase"
      expect(page).to have_link "Next phase", href: "#phase-3-custom-name-for-selecting-phase"
    end

    expect(page).to have_content "Description of accepting phase"
    expect(page).to have_content "January 01, 2018 - January 10, 2018"

    click_link "Custom name for selecting phase"

    expect(page).to have_content "Description of selecting phase"
    expect(page).to have_content "January 21, 2018 - January 31, 2018"

    click_link "Voting projects"

    expect(page).to have_content "Description of balloting phase"
    expect(page).to have_content "March 02, 2018 - March 10, 2018"

    click_link "Current phase Finished budget"

    expect(page).to have_content "Description of finished phase"
    expect(page).to have_content "March 21, 2018 - March 29, 2018"

    expect(page).to have_css(".tabs-panel.is-active", count: 1)
  end

  context "Index map" do
    let(:heading) { create(:budget_heading, budget: budget) }

    before do
      Setting["feature.map"] = true
    end

    scenario "Display default map" do
      visit budget_path(budget)

      within ".map.inline" do
        expect(page).to have_selector("[data-map-center-latitude=\"#{MapLocation.default_latitude}\"]")
        expect(page).to have_selector("[data-map-center-longitude=\"#{MapLocation.default_longitude}\"]")
        expect(page).to have_selector("[data-map-zoom=\"#{MapLocation.default_zoom}\"]")
      end
    end

    scenario "Display custom map" do
      map = create(:map, budget: budget)
      MapLocation.create!(latitude: 30.0, longitude: 40.0, zoom: 5, map: map)

      visit budget_path(budget)

      within ".map.inline" do
        expect(page).to have_selector("[data-map-center-latitude=\"30.0\"]")
        expect(page).to have_selector("[data-map-center-longitude=\"40.0\"]")
        expect(page).to have_selector("[data-map-zoom=\"5\"]")
      end
    end

    scenario "Display investment's map location markers" do
      investment1 = create(:budget_investment, heading: heading)
      investment2 = create(:budget_investment, heading: heading)
      investment3 = create(:budget_investment, heading: heading)

      create(:map_location, longitude: 40.1234, latitude: -3.634, investment: investment1)
      create(:map_location, longitude: 40.1235, latitude: -3.635, investment: investment2)
      create(:map_location, longitude: 40.1236, latitude: -3.636, investment: investment3)

      visit budgets_path

      within ".map_location" do
        expect(page).to have_css(".map-icon", count: 3, visible: :all)
      end
    end

    scenario "Display all investment's map location if there are no selected" do
      budget.update!(phase: :publishing_prices)

      investment1 = create(:budget_investment, heading: heading)
      investment2 = create(:budget_investment, heading: heading)
      investment3 = create(:budget_investment, heading: heading)
      investment4 = create(:budget_investment, heading: heading)

      investment1.create_map_location(longitude: 40.1234, latitude: 3.1234, zoom: 10)
      investment2.create_map_location(longitude: 40.1235, latitude: 3.1235, zoom: 10)
      investment3.create_map_location(longitude: 40.1236, latitude: 3.1236, zoom: 10)
      investment4.create_map_location(longitude: 40.1240, latitude: 3.1240, zoom: 10)

      visit budgets_path

      within ".map_location" do
        expect(page).to have_css(".map-icon", count: 4, visible: :all)
      end
    end

    scenario "Display only selected investment's map location from publishing prices phase" do
      budget.update!(phase: :publishing_prices)

      investment1 = create(:budget_investment, :selected, heading: heading)
      investment2 = create(:budget_investment, :selected, heading: heading)
      investment3 = create(:budget_investment, heading: heading)
      investment4 = create(:budget_investment, heading: heading)

      investment1.create_map_location(longitude: 40.1234, latitude: 3.1234, zoom: 10)
      investment2.create_map_location(longitude: 40.1235, latitude: 3.1235, zoom: 10)
      investment3.create_map_location(longitude: 40.1236, latitude: 3.1236, zoom: 10)
      investment4.create_map_location(longitude: 40.1240, latitude: 3.1240, zoom: 10)

      visit budgets_path

      within ".map_location" do
        expect(page).to have_css(".map-icon", count: 2, visible: :all)
      end
    end

    scenario "Skip invalid map markers" do
      map_locations = []

      investment = create(:budget_investment, heading: heading)

      map_locations << { longitude: 40.123456789, latitude: 3.12345678 }
      map_locations << { longitude: 40.123456789, latitude: "********" }
      map_locations << { longitude: "**********", latitude: 3.12345678 }

      coordinates = map_locations.map do |map_location|
        {
          lat: map_location[:latitude],
          long: map_location[:longitude],
          investment_title: investment.title,
          investment_id: investment.id,
          budget_id: budget.id
        }
      end

      allow_any_instance_of(Budgets::BudgetComponent).to receive(:coordinates).and_return(coordinates)

      visit budgets_path

      within ".map_location" do
        expect(page).to have_css(".map-icon", count: 1, visible: :all)
      end
    end

    scenario "Do not show map if feature is disabled" do
      Setting["feature.map"] = false

      visit budgets_path

      expect(page).not_to have_css ".map"
      expect(page).not_to have_css ".map_location"
      expect(page).not_to have_css ".map-icon"
    end
  end

  context "Show" do
    let!(:budget) { create(:budget, :selecting) }

    scenario "Take into account headings with the same name from a different budget" do
      group1 = create(:budget_group, budget: budget, name: "New York")
      heading1 = create(:budget_heading, group: group1, name: "Brooklyn")
      heading2 = create(:budget_heading, group: group1, name: "Queens")

      budget2 = create(:budget)
      group2 = create(:budget_group, budget: budget2, name: "New York")
      heading3 = create(:budget_heading, group: group2, name: "Brooklyn")
      heading4 = create(:budget_heading, group: group2, name: "Queens")

      visit budget_group_path(budget, group1)

      expect(page).to have_css("#budget_heading_#{heading1.id}")
      expect(page).to have_css("#budget_heading_#{heading2.id}")

      expect(page).not_to have_css("#budget_heading_#{heading3.id}")
      expect(page).not_to have_css("#budget_heading_#{heading4.id}")
    end

    scenario "See results button is showed if the budget has finished" do
      user = create(:user)
      budget = create(:budget, :finished)

      login_as(user)
      visit budget_path(budget)

      expect(page).to have_link "See results"
    end

    scenario "Show investments list" do
      budget = create(:budget, phase: "balloting")
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)

      create_list(:budget_investment, 3, :selected, heading: heading, price: 999)

      visit budget_path(budget)

      within(".investments-list") do
        expect(page).to have_content "List of investments"
        expect(page).to have_content "PRICE", count: 3
      end

      expect(page).to have_link "See all investments",
                                href: budget_investments_path(budget,
                                                              heading_id: budget.headings.first.id,
                                                              filter: "selected")
    end

    scenario "Show investments list when budget has multiple headings" do
      budget = create(:budget, phase: "accepting")
      group = create(:budget_group, budget: budget)
      heading_1 = create(:budget_heading, group: group)
      create(:budget_heading, group: group)

      create_list(:budget_investment, 3, :selected, heading: heading_1, price: 999)

      visit budget_path(budget)

      expect(page).to have_css ".investments-list"
    end

    scenario "Show supports info on selecting phase" do
      budget = create(:budget, :selecting)
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)
      voter = create(:user, :level_two)

      create_list(:budget_investment, 3, :selected, heading: heading, voters: [voter])

      login_as(voter)
      visit budget_path(budget)
      expect(page).not_to have_link "See results"
    end

    scenario "Show link to see all investments" do
      budget = create(:budget)
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)

      create_list(:budget_investment, 3, :winner, heading: heading, price: 999)

      budget.update!(phase: "informing")

      visit budget_path(budget)
      expect(page).not_to have_link "See all investments"

      %w[accepting reviewing selecting valuating].each do |phase_name|
        budget.update!(phase: phase_name)

        visit budget_path(budget)
        expect(page).to have_link "See all investments",
                                  href: budget_investments_path(budget,
                                                                heading_id: budget.headings.first.id,
                                                                filter: "not_unfeasible")
      end

      %w[publishing_prices balloting reviewing_ballots].each do |phase_name|
        budget.update!(phase: phase_name)

        visit budget_path(budget)
        expect(page).to have_link "See all investments",
                                  href: budget_investments_path(budget,
                                                                heading_id: budget.headings.first.id,
                                                                filter: "selected")
      end

      budget.update!(phase: "finished")

      visit budget_path(budget)
      expect(page).to have_link "See all investments",
                                  href: budget_investments_path(budget,
                                                                heading_id: budget.headings.first.id,
                                                                filter: "winners")
    end

    scenario "Show investments list" do
      budget = create(:budget)
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)

      create_list(:budget_investment, 3, :selected, heading: heading, price: 999)

      %w[informing finished].each do |phase_name|
        budget.update!(phase: phase_name)

        visit budget_path(budget)

        expect(page).not_to have_content "List of investments"
        expect(page).not_to have_css ".budget-investment-index-list"
        expect(page).not_to have_css ".budget-investment"
      end

      %w[accepting reviewing selecting].each do |phase_name|
        budget.update!(phase: phase_name)

        visit budget_path(budget)

        expect(page).to have_content "List of investments"
        expect(page).not_to have_content "SUPPORTS"
        expect(page).not_to have_content "PRICE"
      end

      budget.update!(phase: "valuating")

      visit budget_path(budget)

      expect(page).to have_content "List of investments"
      expect(page).to have_content("SUPPORTS", count: 3)
      expect(page).not_to have_content "PRICE"

      %w[publishing_prices balloting reviewing_ballots].each do |phase_name|
        budget.update!(phase: phase_name)

        visit budget_path(budget)

        expect(page).to have_content "List of investments"
        expect(page).to have_content("PRICE", count: 3)
      end
    end

    scenario "Show support info on selecting phase" do
      budget = create(:budget)
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)
      create(:budget_investment, heading: heading)

      voter = create(:user, :level_two)

      %w[informing accepting reviewing valuating publishing_prices balloting reviewing_ballots
        finished].each do |phase_name|
        budget.update!(phase: phase_name)

        visit budget_path(budget)

        expect(page).not_to have_content "It's time to support projects!"
        expect(page).not_to have_content "Support the projects you would like to see move on "\
                                         "to the next phase."
        expect(page).not_to have_content "You may support on as many different projects as you would like."
        expect(page).not_to have_content "So far you've supported 0 projects."
        expect(page).not_to have_content "Log in to start supporting projects."
        expect(page).not_to have_content "There's still time until"
        expect(page).not_to have_content "You can share the projects you have supported on through social "\
                                         "media and attract more attention and support to them!"
        expect(page).not_to have_link    "Keep scrolling to see all ideas"
      end

      budget.update!(phase: "selecting")
      visit budget_path(budget)

      expect(page).to have_content "It's time to support projects!"
      expect(page).to have_content "Support the projects you would like to see move on "\
                                   "to the next phase."
      expect(page).to have_content "You may support on as many different projects as you would like."
      expect(page).to have_content "Log in to start supporting projects"
      expect(page).to have_content "There's still time until"
      expect(page).to have_content "You can share the projects you have supported on through social "\
                                   "media and attract more attention and support to them!"
      expect(page).to have_link    "Keep scrolling to see all ideas"

      login_as(voter)

      visit budget_path(budget)

      expect(page).to have_content "So far you've supported 0 projects."

      create(:budget_investment, :selected, heading: heading, voters: [voter])

      visit budget_path(budget)

      expect(page).to have_content "So far you've supported 1 project."

      create_list(:budget_investment, 3, :selected, heading: heading, voters: [voter])

      visit budget_path(budget)

      expect(page).to have_content "So far you've supported 4 projects."
    end

    scenario "Show supports only for current budget" do
      voter = create(:user, :level_two)

      first_budget = create(:budget, phase: "selecting")
      first_group = create(:budget_group, budget: first_budget)
      first_heading = create(:budget_heading, group: first_group)
      create_list(:budget_investment, 2, :selected, heading: first_heading, voters: [voter])

      second_budget = create(:budget, phase: "selecting")
      second_group = create(:budget_group, budget: second_budget)
      second_heading = create(:budget_heading, group: second_group)
      create_list(:budget_investment, 3, :selected, heading: second_heading, voters: [voter])

      login_as(voter)

      visit budget_path(first_budget)
      expect(page).to have_content "So far you've supported 2 projects."

      visit budget_path(second_budget)
      expect(page).to have_content "So far you've supported 3 projects."
    end

    scenario "Show supports only if the support has not been removed" do
      voter = create(:user, :level_two)
      budget = create(:budget, phase: "selecting")
      investment = create(:budget_investment, :selected, budget: budget)

      login_as(voter)

      visit budget_path(budget)

      expect(page).to have_content "So far you've supported 0 projects."

      visit budget_investment_path(budget, investment)

      within("#budget_investment_#{investment.id}_votes") do
        click_button "Support"

        expect(page).to have_content "You have already supported this investment project."
      end

      visit budget_path(budget)

      expect(page).to have_content "So far you've supported 1 project."

      visit budget_investment_path(budget, investment)

      within("#budget_investment_#{investment.id}_votes") do
        click_button "Remove your support"

        expect(page).to have_content "No supports"
      end

      visit budget_path(budget)

      expect(page).to have_content "So far you've supported 0 projects."
    end
  end

  context "In Drafting phase" do
    before do
      budget.update!(published: false)
      create(:budget)
    end

    context "Listed" do
      scenario "Not listed at public budgets list" do
        visit budgets_path

        expect(page).not_to have_content(budget.name)
      end
    end
  end

  scenario "Phase have link to original image" do
    budget.update!(phase: :finished)
    create(:image, imageable: budget.phases.finished, title: "Phase image")

    visit budgets_path

    expect(page).to have_link(href: budget.phases.finished.image.attachment.url(:original).to_s)
  end
end
