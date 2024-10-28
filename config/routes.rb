Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "static_pages#home"

  # Sign up routes
  post "sign_up", to: "users#create"
  get "sign_up", to: "users#new"

  # Confirmation routes
  resources :confirmations, only: [ :create, :edit, :new ], param: :confirmation_token

  # Sign in routes
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  get "login", to: "sessions#new"

  # Password reset routes
  resources :passwords, only: [ :create, :edit, :new, :update ], param: :password_reset_token

  # Account update routes
  put "account", to: "users#update"
  get "account", to: "users#edit"
  delete "account", to: "users#destroy"

  # Manage sessions routes
  resources :active_sessions, only: [ :destroy ] do
    collection do
      delete "destroy_all"
    end
  end

  # Analytics routes
  post "enable_analytics", to: "analytics#enable", as: :enable_analytics
  delete "clear_history", to: "analytics#clear_history", as: :clear_history
end
