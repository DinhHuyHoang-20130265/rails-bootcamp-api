class SessionsController < Devise::SessionsController
  respond_to :json



  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    yield resource if block_given?

    render json: {
      message: "Signed in successfully.",
      user: ActiveModelSerializers::SerializableResource.new(
        resource, serializer: UserSerializer
      ).as_json
    }
  end

  def destroy
    signed_out = (Devise.sign_out_all_scopes ?
                    sign_out : sign_out(resource_name))
    yield if block_given?

    render json: {
      message: "Signed out successfully."
    }
  end



  private

  def respond_with(resource, _opts = {})
    render json: {
      message: "Logged in successfully.",
      user: ActiveModelSerializers::SerializableResource.new(
        resource, serializer: UserSerializer
      ).as_json
    }
  end

  def respond_to_on_destroy
    render json: {
      message: "Logged out successfully."
    }
  end
end
