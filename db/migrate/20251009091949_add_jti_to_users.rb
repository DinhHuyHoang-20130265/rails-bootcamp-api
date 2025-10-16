class AddJtiToUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :jti, :string
    add_index :users, :jti, unique: true
    
    # Initialize JTI for existing users
    User.find_each do |user|
      user.update_column(:jti, SecureRandom.uuid)
    end
    
    # Make JTI non-nullable
    change_column_null :users, :jti, false
  end
  
  def down
    remove_index :users, :jti
    remove_column :users, :jti
  end
end
