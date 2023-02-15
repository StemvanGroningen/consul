class ChangeDefaultUserNotifications < ActiveRecord::Migration[5.2]
  def change
    change_column_default :users, :public_activity, from: true, to: false
    change_column_default :users, :newsletter, from: true, to: false
    change_column_default :users, :email_on_comment, from: false, to: true
    change_column_default :users, :email_on_comment_reply, from: false, to: true
  end
end
