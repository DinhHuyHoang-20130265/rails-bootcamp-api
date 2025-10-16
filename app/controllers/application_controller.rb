class ApplicationController < ActionController::API
  respond_to :json

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :set_cors_headers

  rescue_from ActionController::InvalidAuthenticityToken,
              with: :handle_invalid_token
  rescue_from JWT::DecodeError, with: :handle_jwt_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActionController::ParameterMissing,
              with: :handle_parameter_missing

  def authenticate_user!
    super
  rescue ActionController::InvalidAuthenticityToken => e
    Rails.logger.debug "InvalidAuthenticityToken: #{e}"

    render json: { error: "Invalid authentication token" },
           status: :unauthorized
  rescue JWT::DecodeError => e
    Rails.logger.debug "JWT::DecodeError: #{e}"

    render json: { error: "Invalid token" }, status: :unauthorized
  end

  private

  def set_cors_headers
    headers["Access-Control-Allow-Origin"] = "*"
    headers["Access-Control-Allow-Methods"] = "POST, PUT, DELETE, GET, OPTIONS"
    headers["Access-Control-Request-Method"] = "*"
    headers["Access-Control-Allow-Headers"] = "Origin, X-Requested-With,
      Content-Type, Accept, Authorization"
  end

  def handle_invalid_token(exception)
    Rails.logger.debug "InvalidAuthenticityToken: #{exception}"

    render json: { error: "Invalid authentication token" },
           status: :unauthorized
  end

  def handle_jwt_error(exception)
    Rails.logger.debug "JWT::DecodeError: #{exception}"

    render json: { error: "Invalid token" }, status: :unauthorized
  end

  def handle_not_found(exception)
    Rails.logger.debug "RecordNotFound: #{exception}"

    render json: { error: "Resource not found" }, status: :not_found
  end

  def handle_parameter_missing(exception)
    Rails.logger.debug "ParameterMissing: #{exception}"

    render json: { error: "Missing required parameter: #{exception.param}" },
           status: :bad_request
  end

  def handle_options
    head :ok
  end

  def health
    render json: {
      status: "ok",
      message: "API is running",
      timestamp: Time.current.iso8601
    }
  end

  protected

  def configure_permitted_parameters
    added_attrs = [
      :username, :display_name, :email, :password,
      :password_confirmation, :current_password, :remember_me
    ]

    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: [ :username, :password ]
  end
end
