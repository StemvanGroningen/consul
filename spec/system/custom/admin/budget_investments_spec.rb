require "rails_helper"

describe "Admin budget investments", :admin do
  it_behaves_like "admin nested imageable",
                  "budget_investment",
                  "edit_admin_budget_budget_investment_path",
                  { budget_id: "budget_id", id: "id" },
                  "imageable_fill_new_valid_budget_investment",
                  "Update",
                  "Investment project updated succesfully."

  it_behaves_like "admin nested documentable",
                  "administrator",
                  "budget_investment",
                  "edit_admin_budget_budget_investment_path",
                  { budget_id: "budget_id", id: "id" },
                  "documentable_fill_new_valid_budget_investment",
                  "Update",
                  "Investment project updated succesfully."
end
