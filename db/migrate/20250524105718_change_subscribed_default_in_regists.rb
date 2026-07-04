class ChangeSubscribedDefaultInRegists < ActiveRecord::Migration[7.1]
  def change
    change_column_default :regists, :subscribed, false
    change_column_null :regists, :subscribed, false
  end
end
