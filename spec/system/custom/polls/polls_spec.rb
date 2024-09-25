require "rails_helper"

describe "Polls" do
  describe "Index" do
    scenario "Polls display list of questions" do
      poll = create(:poll, :with_image)
      question1 = create(:poll_question, :yes_no, poll: poll)
      question2 = create(:poll_question, :yes_no, poll: poll)

      visit polls_path

      expect(page).to have_content(poll.name)
      expect(page).to have_content(question1.title)
      expect(page).to have_content(question2.title)
    end

    scenario "Polls display remaining days to participate if not expired" do
      create(:poll, starts_at: Time.current, ends_at: 11.days.from_now)
      create(:poll, :expired)

      visit polls_path

      within(".poll") do
        expect(page).to have_content("Remaining 11 days to participate")
      end

      click_link "Expired"

      within(".poll") do
        expect(page).not_to have_content("Remaining")
        expect(page).not_to have_content("days to participate")
      end
    end

    scenario "Polls display remaining hours to participate if not expired" do
      create(:poll, starts_at: Time.current, ends_at: 8.hours.from_now)
      create(:poll, :expired)

      visit polls_path

      within(".poll") do
        expect(page).to have_content("Remaining about 8 hours to participate")
      end

      click_link "Expired"

      within(".poll") do
        expect(page).not_to have_content("Remaining")
        expect(page).not_to have_content("days to participate")
      end
    end

    scenario "Expired polls are ordered by ends date" do
      travel_to "01/07/2023".to_date do
        create(:poll, starts_at: "03/05/2023", ends_at: "01/06/2023", name: "Expired poll one")
        create(:poll, starts_at: "02/05/2023", ends_at: "02/06/2023", name: "Expired poll two")
        create(:poll, starts_at: "01/05/2023", ends_at: "03/06/2023", name: "Expired poll three")
        create(:poll, starts_at: "04/05/2023", ends_at: "04/06/2023", name: "Expired poll four")
        create(:poll, starts_at: "05/05/2023", ends_at: "05/06/2023", name: "Expired poll five")

        visit polls_path(filter: "expired")

        expect("Expired poll five").to appear_before("Expired poll four")
        expect("Expired poll four").to appear_before("Expired poll three")
        expect("Expired poll three").to appear_before("Expired poll two")
        expect("Expired poll two").to appear_before("Expired poll one")
      end
    end

    scenario "Already participated in a poll" do
      poll_with_question = create(:poll)
      question = create(:poll_question, :yes_no, poll: poll_with_question)

      login_as(create(:user, :level_two))
      visit polls_path

      vote_for_poll_via_web(poll_with_question, question, "Yes")

      visit polls_path

      expect(page).to have_css(".message .callout .fa-check-circle", count: 1)
      expect(page).to have_content("You already have participated in this poll")
    end

    scenario "Poll title and button link to stats if enabled" do
      poll = create(:poll, :expired, name: "Poll with stats", stats_enabled: true)

      visit polls_path(filter: "expired")

      expect(page).to have_link("Poll with stats", href: stats_poll_path(poll.slug))
      expect(page).to have_link("Poll ended", href: stats_poll_path(poll.slug))
    end

    scenario "Poll title and button link to results if enabled" do
      poll = create(:poll, :expired, name: "Poll with results", stats_enabled: true, results_enabled: true)

      visit polls_path(filter: "expired")

      expect(page).to have_link("Poll with results", href: results_poll_path(poll.slug))
      expect(page).to have_link("Poll ended", href: results_poll_path(poll.slug))
    end

    scenario "Poll 14 links to Maptionnaire" do
      poll = create(:poll, id: 14)

      visit polls_path

      within(".poll") do
        expect(page).to have_link(poll.name, href: "https://new.maptionnaire.com/q/7n929t4zty87")
        expect(page).to have_link("Participate in this poll",
                                  href: "https://new.maptionnaire.com/q/7n929t4zty87")
      end
    end
  end

  context "Show" do
    let(:geozone) { create(:geozone) }
    let(:poll) { create(:poll, summary: "Summary", description: "Description") }

    scenario "Do not show question number in polls with one question" do
      question = create(:poll_question, poll: poll)

      visit poll_path(poll)

      expect(page).to have_content question.title
      expect(page).not_to have_content("Question 1")
    end

    scenario "Question appear by created at order" do
      question = create(:poll_question, poll: poll, title: "First question")
      create(:poll_question, poll: poll, title: "Second question")
      question_3 = create(:poll_question, poll: poll, title: "Third question")

      visit polls_path
      expect("First question").to appear_before("Second question")
      expect("Second question").to appear_before("Third question")

      visit poll_path(poll)

      expect("First question").to appear_before("Second question")
      expect("Second question").to appear_before("Third question")

      question_3.update!(title: "Third question edited")
      question.update!(title: "First question edited")

      visit polls_path
      expect("First question edited").to appear_before("Second question")
      expect("Second question").to appear_before("Third question edited")

      visit poll_path(poll)

      expect("First question edited").to appear_before("Second question")
      expect("Second question").to appear_before("Third question edited")
    end

    scenario "Read more button appears only in long answer descriptions" do
      question = create(:poll_question, poll: poll)
      option_long = create(:poll_question_option,
                           title: "Long answer",
                           question: question,
                           description: Faker::Lorem.characters(number: 700))
      create(:poll_question_option,
             title: "Short answer",
             question: question,
             description: Faker::Lorem.characters(number: 100))

      visit poll_path(poll)

      expect(page).to have_content "Long answer"
      expect(page).to have_content "Short answer"
      expect(page).to have_css "#option_description_#{option_long.id}.option-description.short"

      within "#poll_more_info_options" do
        expect(page).to have_content "Read more about Long answer"
        expect(page).not_to have_content "Read more about Short answer"
      end

      find("#read_more_#{option_long.id}").click

      expect(page).to have_content "Read less about Long answer"
      expect(page).to have_css "#option_description_#{option_long.id}.option-description"
      expect(page).not_to have_css "#option_description_#{option_long.id}.option-description.short"

      find("#read_less_#{option_long.id}").click

      expect(page).to have_content "Read more about Long answer"
      expect(page).to have_css "#option_description_#{option_long.id}.option-description.short"
    end

    scenario "Show orbit bullets and controls only when there is more than one image" do
      poll = create(:poll)
      question = create(:poll_question, poll: poll)
      option_1 = create(:poll_question_option, title: "Answer with one image", question: question)
      option_2 = create(:poll_question_option, title: "Answer with two images", question: question)
      create(:image, imageable: option_1)
      create(:image, imageable: option_2)
      create(:image, imageable: option_2)

      visit poll_path(poll)

      within("div#option_#{option_1.id}") do
        expect(page).not_to have_css ".orbit-previous"
        expect(page).not_to have_css ".orbit-next"
      end

      within("div#option_#{option_2.id}") do
        expect(page).to have_css ".orbit-previous"
        expect(page).to have_css ".orbit-next"
      end
    end

    scenario "Question answers appear in the given order" do
      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_option, title: "First", question: question, given_order: 2)
      answer2 = create(:poll_question_option, title: "Second", question: question, given_order: 1)

      visit poll_path(poll)

      within("div#poll_question_#{question.id}") do
        expect(answer2.title).to appear_before(answer1.title)
      end
    end

    scenario "More info answers appear in the given order" do
      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_option, title: "First", question: question, given_order: 2)
      answer2 = create(:poll_question_option, title: "Second", question: question, given_order: 1)

      visit poll_path(poll)

      within("div.poll-more-info-options") do
        expect(answer2.title).to appear_before(answer1.title)
      end
    end

    scenario "Answer images are shown" do
      question = create(:poll_question, :yes_no, poll: poll)
      create(:image, imageable: question.question_options.first, title: "The yes movement")

      visit poll_path(poll)

      expect(page).to have_css "img[alt='The yes movement']"
    end
  end
end
