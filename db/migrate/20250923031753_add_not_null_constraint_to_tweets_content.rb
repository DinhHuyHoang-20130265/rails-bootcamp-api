class AddNotNullConstraintToTweetsContent < ActiveRecord::Migration[8.0]
  def change
    change_column_null :tweets, :content, false
  end
end
