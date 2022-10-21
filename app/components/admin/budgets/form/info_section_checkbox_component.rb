class Admin::Budgets::Form::InfoSectionCheckboxComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  include Admin::Namespace

  attr_reader :form
  alias_method :f, :form

  def initialize(form)
    @form = form
  end
end
