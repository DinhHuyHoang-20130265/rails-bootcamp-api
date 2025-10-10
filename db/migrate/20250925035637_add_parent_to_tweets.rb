class AddParentToTweets < ActiveRecord::Migration[8.0]
  def change
    add_reference :tweets, :parent, foreign_key: { to_table: :tweets }
  end
end
