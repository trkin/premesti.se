Rails.application.routes.draw do
  root to: 'pages#index'
  devise_for :users, controllers: {
    omniauth_callbacks: :omniauth_callbacks,
    confirmations: :confirmations
  }

  post 'landing-signup', to: 'pages#landing_signup'

  get 'dashboard', to: 'dashboard#index'
end
