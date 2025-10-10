class UsersController < Devise::RegistrationsController

  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  def create
    @form = UserForm.new(User.new)

    if @form.validate(sign_up_params) && @form.save
      render json: { message: "signed up successfully, please sign in" }, status: :created
    else
      render json: { errors: @form.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @form = UserForm.new(current_user)

    if @form.validate(account_update_params) && @form.save
      render json: {
        user: ActiveModelSerializers::SerializableResource.new(
          @form.model, serializer: UserSerializer).as_json }, status: :ok
    else
      render json: { errors: @form.errors.messages }, status: :unprocessable_entity
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
end
