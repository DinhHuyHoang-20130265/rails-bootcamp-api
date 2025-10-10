class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :tweets, dependent: :destroy

  # --- Make email optional for Devise ---
  def email_required?
    false
  end

  # For Devise/ActiveModel change tracking (Rails 5+)
  def will_save_change_to_email?
    false
  end
end
