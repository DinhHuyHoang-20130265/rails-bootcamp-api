class UsersController < ApplicationController
  respond_to :json
  before_action :authenticate_user!



  def me
    render json: {
      user: ActiveModelSerializers::SerializableResource.new(
        current_user, serializer: UserSerializer
      ).as_json
    }, status: :ok
  end

  def update
    @form = UserForm.new(current_user)

    if @form.validate(account_update_params) && @form.save
      render json: {
        user: ActiveModelSerializers::SerializableResource.new(
          @form.model, serializer: UserSerializer).as_json }, status: :ok
    else
      render json: { errors: @form.errors.messages },
             status: :unprocessable_entity
    end
  end



  private

  def account_update_params
    params.require(:user).permit(
      :username, :email, :display_name, :current_password
    )
  end
end
