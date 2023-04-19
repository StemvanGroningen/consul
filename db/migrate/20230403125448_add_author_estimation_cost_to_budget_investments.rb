class AddAuthorEstimationCostToBudgetInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_investments, :author_estimation_cost, :bigint
  end
end
