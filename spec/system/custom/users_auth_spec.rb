require "rails_helper"

describe "Users" do
  context "Regular authentication" do
    context "Sign up" do
      scenario "Success" do
        message = "You have been sent a message containing a verification link. " \
                  "Please click on this link to activate your account."
        visit "/"
        click_link "Sign in"
        click_link "Register a new account"

        fill_in "Username", with: "Manuela Carmena"
        fill_in "Email", with: "manuela@consul.dev"
        fill_in "Password", with: "judgementday"
        fill_in "Confirm password", with: "judgementday"
        check "user_terms_of_service"

        click_button "Register"

        expect(page).to have_content message

        confirm_email

        expect(page).to have_content "Your account has been confirmed."
      end

      scenario "User already confirmed email with the token" do
        message = "You have been sent a message containing a verification link. " \
                  "Please click on this link to activate your account."
        visit "/"
        click_link "Sign in"
        click_link "Register a new account"

        fill_in "Username", with: "Manuela Carmena"
        fill_in "Email", with: "manuela@consul.dev"
        fill_in "Password", with: "judgementday"
        fill_in "Confirm password", with: "judgementday"
        check "user_terms_of_service"

        click_button "Register"

        expect(page).to have_content message

        confirm_email
        expect(page).to have_content "Your account has been confirmed."

        sent_token = /.*confirmation_token=(.*)".*/.match(ActionMailer::Base.deliveries.last.body.to_s)[1]
        visit user_confirmation_path(confirmation_token: sent_token)

        expect(page).to have_content "You have already been verified; please attempt to sign in."
      end
    end

    scenario "Re-send confirmation instructions" do
      create(:user, email: "manuela@consul.dev", confirmed_at: nil)
      ActionMailer::Base.deliveries.clear

      visit "/"
      click_link "Sign in"
      expect(page).to have_content "Haven't received instructions to activate your account?"
      click_link "Click here"

      fill_in "Email", with: "manuela@consul.dev"
      click_button "Re-send instructions"

      expect(page).to have_content "If your email address exists in our database, " \
                                   "in a few minutes you will receive an email with instructions " \
                                   "on how to confirm your email address."
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.to).to eq(["manuela@consul.dev"])
      expect(ActionMailer::Base.deliveries.first.subject).to eq("Confirmation instructions")
    end

    scenario "Re-send confirmation instructions with unexisting email" do
      ActionMailer::Base.deliveries.clear
      visit "/"
      click_link "Sign in"
      expect(page).to have_content "Haven't received instructions to activate your account?"
      click_link "Click here"

      fill_in "Email", with: "fake@mail.dev"
      click_button "Re-send instructions"

      expect(page).to have_content "If your email address exists in our database, " \
                                   "in a few minutes you will receive an email with instructions " \
                                   "on how to confirm your email address."
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end

    scenario "Re-send confirmation instructions with already verified email" do
      ActionMailer::Base.deliveries.clear

      create(:user, email: "manuela@consul.dev")

      visit new_user_session_path
      expect(page).to have_content "Haven't received instructions to activate your account?"
      click_link "Click here"

      fill_in "user_email", with: "manuela@consul.dev"
      click_button "Re-send instructions"

      expect(page).to have_content "If your email address exists in our database, " \
                                   "in a few minutes you will receive an email with instructions " \
                                   "on how to confirm your email address."
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.to).to eq(["manuela@consul.dev"])
      expect(ActionMailer::Base.deliveries.first.subject).to eq("Your account is already confirmed")
    end
  end

  context "Regular authentication with password complexity enabled" do
    before do
      allow(Rails.application).to receive(:secrets).and_return(ActiveSupport::OrderedOptions.new.merge(
        security: { password_complexity: true }
      ))
    end

    context "Sign up" do
      scenario "Success with password" do
        message = "You have been sent a message containing a verification link. Please click on this" \
                  " link to activate your account."
        visit "/"
        click_link "Sign in"
        click_link "Register a new account"

        fill_in "Username", with: "Manuela Carmena"
        fill_in "Email", with: "manuela@consul.dev"
        fill_in "Password", with: "ValidPassword1234"
        fill_in "Confirm password", with: "ValidPassword1234"
        check "user_terms_of_service"

        click_button "Register"

        expect(page).to have_content message

        confirm_email

        expect(page).to have_content "Your account has been confirmed."
      end

      scenario "Errors on sign up" do
        visit "/"
        click_link "Sign in"
        click_link "Register a new account"

        fill_in "Username", with: "Manuela Carmena"
        fill_in "Email", with: "manuela@consul.dev"
        fill_in "Password", with: "invalid_password"
        fill_in "Confirm password", with: "invalid_password"
        check "user_terms_of_service"

        click_button "Register"

        expect(page).to have_content "must contain at least one digit, must contain at least one" \
                                     " upper-case letter"
      end
    end
  end
end
