class Layout::SubnavigationComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "layout", "subnavigation_component").to_s

class Layout::SubnavigationComponent < ApplicationComponent
  delegate :current_user, to: :helpers

  def budgets
    Budget.open_budgets_for(current_user)
  end
end
