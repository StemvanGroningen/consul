require "rails_helper"

describe "Multitenancy", :seed_tenants do
  before { create(:tenant, schema: "mars") }

  scenario "PostgreSQL extensions work for tenants" do
    Tenant.switch("mars") { login_as(create(:user)) }

    with_subdomain("mars") do
      visit new_proposal_path
      fill_in "Proposal title", with: "Use the unaccent extension in Mars"
      fill_in "Proposal summary", with: "tsvector for María the Martian"

      check "proposal_terms_of_service"
      click_button "Create proposal"

      expect(page).to have_content "Proposal created successfully."

      click_link "No, I want to publish the proposal"

      expect(page).to have_content "You've created a proposal!"

      visit proposals_path
      click_button "Advanced search"
      fill_in "With the text", with: "Maria the Martian"
      click_button "Filter"

      expect(page).to have_content "Search results"
      expect(page).to have_content "María the Martian"
    end
  end

  scenario "Creating content in one tenant doesn't affect other tenants" do
    create(:tenant, schema: "venus")
    Tenant.switch("mars") { login_as(create(:user)) }

    with_subdomain("mars") do
      visit new_debate_path
      fill_in "Debate title", with: "Found any water here?"
      fill_in_ckeditor "Initial debate text", with: "Found any water here?"

      check "debate_terms_of_service"
      click_button "Start a debate"

      expect(page).to have_content "Debate created successfully."
      expect(page).to have_content "Found any water here?"
    end

    with_subdomain("venus") do
      visit debates_path

      expect(page).to have_content "Sign in"
      expect(page).not_to have_css ".debate"

      visit new_debate_path

      expect(page).to have_content "You must sign in or register to continue."
    end
  end

  scenario "Sign up into subdomain" do
    with_subdomain("mars") do
      visit new_user_registration_path

      fill_in "Username", with: "Marty McMartian"
      fill_in "Email", with: "marty@consul.dev"
      fill_in "Password", with: "012345678910"
      fill_in "Confirm password", with: "012345678910"
      check "By registering you accept the terms and conditions of use"
      click_button "Register"

      expect(page).to have_content "You have been sent a message containing a verification link"

      confirm_email

      expect(page).to have_content "Your account has been confirmed."
    end
  end

  scenario "Users from another tenant can't sign in" do
    create(:tenant, schema: "venus")
    Tenant.switch("mars") { create(:user, email: "marty@consul.dev", password: "012345678910") }

    with_subdomain("mars") do
      visit new_user_session_path
      fill_in "Email or username", with: "marty@consul.dev"
      fill_in "Password", with: "012345678910"
      click_button "Enter"

      expect(page).to have_content "You have been signed in successfully."
    end

    with_subdomain("venus") do
      visit new_user_session_path
      fill_in "Email or username", with: "marty@consul.dev"
      fill_in "Password", with: "012345678910"
      click_button "Enter"

      expect(page).to have_content "Invalid Email or username or password."
    end
  end
end
