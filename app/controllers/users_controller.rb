class UsersController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  def new
    @form = UserForm.new(User.new)
    super
  end

  def create
    @form = UserForm.new(User.new)

    if @form.validate(sign_up_params) && @form.save
      set_flash_message! :notice, :signed_up
      sign_up(resource_name, @form.model)
      redirect_to redirect_to_root(@form.model)
    else
      clean_up_passwords @form.model
      set_minimum_password_length
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @form = UserForm.new(current_user)
    super
  end

  def update
    @form = UserForm.new(current_user)

    if @form.validate(account_update_params) && @form.save
        set_flash_message! :notice, :updated
        redirect_to redirect_to_root(@form.model)
    else
      clean_up_passwords @form.model
      set_minimum_password_length
      render :edit, status: :unprocessable_content
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(
      :sign_up, keys: [ :username, :display_name ])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(
      :account_update, keys: [
        :username,
        :display_name,
        :current_password
      ])
  end

  def redirect_to_root(resource)
    root_path
  end
end
