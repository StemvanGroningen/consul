class AddInfoSectionToBudgets < ActiveRecord::Migration[5.2]
  def change
    add_column :budgets, :info_section, :boolean, default: false
    add_column :budget_translations, :info_section_title, :string
    add_column :budget_translations, :info_section_description, :text
    add_column :budget_translations, :info_section_link_text, :string
    add_column :budget_translations, :info_section_link_url, :string
  end
end
