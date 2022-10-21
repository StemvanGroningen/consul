class Admin::Budgets::Form::InfoSectionDataComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  include Admin::Namespace

  attr_reader :form
  alias_method :translations_form, :form

  def initialize(form)
    @form = form
  end
end
