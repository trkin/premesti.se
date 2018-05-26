# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  root to: 'pages#home'
  devise_for :users, controllers: {
    omniauth_callbacks: :omniauth_callbacks,
    confirmations: :confirmations
  }

  post 'landing-signup', to: 'pages#landing_signup'
  get 'privacy-policy', to: 'pages#privacy_policy'
  get 'faq', to: 'pages#faq'
  get 'contact', to: 'pages#contact'
  post 'contact', to: 'pages#submit_contact'
  get 'find_on_map', to: 'pages#find_on_map'
  get 'select2_locations', to: 'pages#select2_locations'
  get 'sign_in_as', to: 'application#sign_in_as'

  get 'dashboard', to: 'dashboard#index'
  resources :moves do
    collection do
      post :create_from_group
    end
    member do
      post :create_to_group
      delete :destroy_to_group
    end
  end

  resources :chats, only: %i[show destroy] do
    member do
      post :create_message
      delete :destroy_message
      patch :report_message
    end
  end

  namespace :admin do
    get :dashboard
    resources :users
    get :reported_messages
    resources :locations
    resources :groups
  end
end
