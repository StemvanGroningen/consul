class AddPolisToPolls < ActiveRecord::Migration[5.1]
  def change
    add_column :polls, :polis, :boolean, default: false
    add_column :polls, :polis_url, :string
    add_column :polls, :polis_report_url, :string
  end
end
