require "rails_helper"

describe User do
  describe "preferences" do
    describe "email_on_comment" do
      it "is true by default" do
        expect(subject.email_on_comment).to be true
      end
    end

    describe "email_on_comment_reply" do
      it "is true by default" do
        expect(subject.email_on_comment_reply).to be true
      end
    end
  end
end
