Rails.application.routes.draw do
  root to: 'pages#index'
  devise_for :users, controllers: {
    omniauth_callbacks: :omniauth_callbacks,
    confirmations: :confirmations
  }

  post 'landing-signup', to: 'pages#landing_signup'
  get 'privacy-policy', to: 'pages#privacy_policy'
  get 'find_on_map', to: 'pages#find_on_map'
  get 'select2_locations', to: 'pages#select2_locations'

  get 'dashboard', to: 'dashboard#index'
  resources :moves do
    member do
      post :create_to_group
      delete :destroy_to_group
    end
  end

  namespace :admin do
    get :dashboard
    resources :locations
    resources :groups
  end
end
