class RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params

  def create
    @form = UserForm.new(User.new)
    validation_result = @form.validate(user_params)

    if validation_result
      save_result = @form.save
      if save_result
        render json: {
          message: "signed up successfully, please sign in"
        }, status: :created
      else
        render json: {
          errors: @form.model.errors.full_messages
        }, status: :unprocessable_entity
      end
    else
      render json: {
        errors: @form.errors.full_messages
      }, status: :unprocessable_entity
    end
  end



  private

  def user_params
    params.require(:user).permit(
      :username, :display_name, :email, :password, :password_confirmation
    )
  end



  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(
      :sign_up, keys: [ :username, :display_name ]
    )
  end
end
