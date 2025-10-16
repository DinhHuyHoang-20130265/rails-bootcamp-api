class UserForm < Reform::Form
  property :username
  property :display_name
  property :email
  property :password, empty: true
  property :password_confirmation, virtual: true
  property :current_password, virtual: true

  validates :display_name, presence: true
  validates :username, presence: true, length: { minimum: 3 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP },
            allow_blank: true
  validates :password, presence: true,
            format: {
              with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}\z/,
              message: "must be at least 8 characters,
                        include uppercase, lowercase, and numbers,
                        and contain only letters and digits"
            },
            if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?
  validates :current_password, presence: true, if: :current_password_required?
  validate :passwords_match, if: :password_changed?
  validate :current_password_valid, if: :current_password_required?
  validate :username_uniqueness

  def save
    if password.blank?
      # If password is blank, update only non-password fields
      model.assign_attributes(username: username,
                              display_name: display_name,
                              email: email
      )
      model.save
    else
      # If password is present, use normal save
      super
    end
  end

  private

  def password_required?
    # Password is required for new records or when password is being changed
    !model.persisted? || password.present?
  end

  def password_changed?
    # Check if password is being changed (not empty)
    password.present?
  end

  def current_password_required?
    # Current password is required for existing users (profile updates)
    model.persisted?
  end

  def passwords_match
    if password != password_confirmation
      errors.add(:password_confirmation, "must match password")
    end
  end

  def current_password_valid
    return unless current_password.present?

    unless model.valid_password?(current_password)
      errors.add(:current_password, "is incorrect")
    end
  end

  def username_uniqueness
    return unless username.present?

    existing_user = User.where("LOWER(username) = ?", username.downcase)

    if model.persisted?
      existing_user = existing_user.where.not(id: model.id)
    end

    if existing_user.exists?
      errors.add(:username, "has already been taken")
    end
  end
end
