class AddUsernameAndDisplayNameToUsers < ActiveRecord::Migration[8.0]
  def change
    # Add columns (NOT NULL)
    add_column :users, :username, :string, null: false
    add_column :users, :display_name, :string, null: false

    # Unique index on username
    add_index :users, :username, unique: true

    # Make email optional (nullable, no default "")
    change_column_default :users, :email, from: "", to: nil
    change_column_null :users, :email, true
    # Keep the existing unique index on email if you still want emails (when present)
    # Devise's default migration already added: add_index :users, :email, unique: true
  end
end
