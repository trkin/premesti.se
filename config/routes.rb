Rails.application.routes.draw do
  root to: 'pages#index'
  devise_for :users, controllers: {
    omniauth_callbacks: :omniauth_callbacks,
    confirmations: :confirmations
  }

  post 'landing-signup', to: 'pages#landing_signup'
  get 'privacy-policy', to: 'pages#privacy_policy'

  get 'dashboard', to: 'dashboard#index'
  resources :moves

  namespace :admin do
    get :dashboard
    resources :locations
    resources :groups
  end
end
