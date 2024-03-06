require "rails_helper"

describe Shared::AgreeWithTermsOfServiceFieldComponent do
  before do
    dummy_model = Class.new do
      include ActiveModel::Model
      attr_accessor :terms_of_service
    end

    stub_const("DummyModel", dummy_model)
  end

  let(:form) { ConsulFormBuilder.new(:dummy, DummyModel.new, ApplicationController.new.view_context, {}) }
  let(:component) { Shared::AgreeWithTermsOfServiceFieldComponent.new(form) }

  it "contains a hidden field with terms of service accepted" do
    render_inline component

    expect(page).to have_css "input[type=hidden]", visible: :hidden
    expect(page).to have_css "input[id=dummy_terms_of_service]", visible: :hidden
    expect(page).to have_css "input[value=1]", visible: :hidden
  end
end
