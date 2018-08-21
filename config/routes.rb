require 'sidekiq/web'
# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
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
  get 'my-move/:id/:some_name', to: 'pages#my_move', as: :my_move
  post 'my-move/:id/:some_name', to: 'pages#submit_my_move'

  get 'sample-error', to: 'pages#sample_error'
  get 'sample-error-in-javascript', to: 'pages#sample_error_in_javascript'
  get 'sample-error-in-javascript-ajax', to: 'pages#sample_error_in_javascript_ajax'
  post 'notify-javascript-error', to: 'pages#notify_javascript_error'
  get 'sample-error-in-sidekiq', to: 'pages#sample_error_in_sidekiq'

  get 'sign_in_as', to: 'application#sign_in_as'

  get 'dashboard', to: 'dashboard#index'
  get 'resend-confirmation-instructions', to: 'dashboard#resend_confirmation_instructions'

  get 'my-settings', to: 'my_settings#index'
  patch 'my-settings', to: 'my_settings#update'
  get 'my-data', to: 'my_settings#my_data'

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
      delete :archive_message
      patch :report_message
      post :archive
    end
  end

  namespace :admin do
    get :dashboard
    resources :users
    resources :chats
    get :reported_messages
    resources :locations
    resources :groups
  end
end
# rubocop:enable Metrics/BlockLength
