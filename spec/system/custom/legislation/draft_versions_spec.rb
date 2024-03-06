require "rails_helper"

describe "Legislation Draft Versions" do
  context "Annotations" do
    let(:user) { create(:user) }
    let(:draft_version) { create(:legislation_draft_version, :published) }

    before { login_as user }

    scenario "When page is restored from browser cache do not duplicate annotation handlers" do
      Setting["org_name"] = "CONSUL"
      create(:legislation_annotation, draft_version: draft_version, text: "my annotation")

      visit legislation_process_draft_version_path(draft_version.process, draft_version)

      expect(page).to have_css(".annotator-hl", count: 1)

      click_link "CONSUL"

      expect(page).to have_content "Most active debates"

      go_back

      expect(page).to have_content "A collaborative legislation process"
      expect(page).to have_css(".annotator-hl", count: 1)
    end

    scenario "When page is restored from browser cache publish comment button keeps working" do
      Setting["org_name"] = "CONSUL"
      create(:legislation_annotation, draft_version: draft_version, text: "my annotation")

      visit legislation_process_draft_version_path(draft_version.process, draft_version)

      find(:css, ".annotator-hl").click

      expect(page).to have_link "Publish Comment"

      click_link "CONSUL"

      expect(page).to have_content "Most active debates"

      go_back

      expect(page).to have_content "A collaborative legislation process"

      click_link "Publish Comment"
      fill_in "comment[body]", with: "My interesting comment"
      click_button "Publish comment"

      expect(page).to have_content "My interesting comment"
    end

    scenario "Comments are disabled when allegations phase is closed" do
      travel_to "01/01/2022".to_date

      process = create(:legislation_process, allegations_start_date: "01/01/2022",
                                             allegations_end_date: "31/01/2022")

      draft = create(:legislation_draft_version, process: process)

      note = create(:legislation_annotation,
                    draft_version: draft, text: "First comment", quote: "audiam",
                    ranges: [{ "start" => "/p[3]", "startOffset" => 6, "end" => "/p[3]", "endOffset" => 11 }])

      visit legislation_process_draft_version_annotation_path(process, draft, note)

      within "#comments" do
        expect(page).to have_content "First comment"
        fill_in "Leave your comment", with: "Second comment"
        click_button "Publish comment"
      end

      within "#comments" do
        expect(page).to have_content "First comment"
        expect(page).to have_content "Second comment"
      end

      travel_to "01/02/2022".to_date

      visit legislation_process_draft_version_annotation_path(process, draft, note)

      within "#comments" do
        expect(page).to have_content "Comments are closed"
        expect(page).not_to have_content "Leave your comment"
        expect(page).not_to have_content "Publish comment"
      end

      travel_back
    end
  end
end
