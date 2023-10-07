require "rails_helper"

describe AdminLegislationSanitizer do
  let(:sanitizer) { AdminLegislationSanitizer.new }

  describe "#sanitize" do
    it "allows style" do
      html = 'Dangerous<img src="/smile.png" alt="Smile" style="width:10px;"> image'
      expect(sanitizer.sanitize(html)).to eq(html)
    end
  end
end
