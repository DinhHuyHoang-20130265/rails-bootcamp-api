Rails.application.routes.draw do
  # Handle preflight OPTIONS requests
  match "*path", to: "application#handle_options",
        via: :options, constraints: { format: :json }

  defaults format: :json do
    # Authentication routes
    devise_for :users, controllers: {
      registrations: "registrations",
      sessions: "sessions"
    }, skip: [ :confirmations, :passwords, :unlocks ]

    # User profile routes (separate from registration)
    resources :users, only: [ :update ] do
      collection do
        get :me
        patch :update
      end
    end

    # Tweet routes
    resources :tweets do
      # Reply routes nested under tweets
      resources :replies
    end

    # Health check route
    get "up" => "rails/health#show", as: :rails_health_check

    # API health check
    get "api/health", to: "application#health"

    # Root path (optional - can be configured later)
    # root "tweets#index"
  end
end
