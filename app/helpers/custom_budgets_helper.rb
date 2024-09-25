module CustomBudgetsHelper
  def show_unselected_link_to_budget_investments(budget)
    ["balloting", "reviewing_ballots"].include? budget.phase
  end
end
