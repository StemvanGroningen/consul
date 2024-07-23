class Layout::SubnavigationComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "layout", "subnavigation_component.rb")

class Layout::SubnavigationComponent < ApplicationComponent
  delegate :current_user, to: :helpers

  def budgets
    Budget.open_budgets_for(current_user)
  end
end
