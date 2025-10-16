class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self
  has_many :tweets, dependent: :destroy
  before_create :generate_jti

  # --- Make email optional for Devise ---
  def email_required?
    false
  end

  # For Devise/ActiveModel change tracking (Rails 5+)
  def will_save_change_to_email?
    false
  end



  private

  def generate_jti
    self.jti = SecureRandom.uuid
  end
end
