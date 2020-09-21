require 'sidekiq/web'
# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  root to: 'pages#home'
  devise_for :users, controllers: {
    omniauth_callbacks: 'devise/my_omniauth_callbacks',
    confirmations: 'devise/my_confirmations',
    registrations: 'devise/my_registrations',
  }

  post 'landing-signup', to: 'pages#landing_signup'
  get 'privacy-policy', to: 'pages#privacy_policy'
  get 'faq', to: 'pages#faq'
  get 'contact', to: 'pages#contact'
  post 'contact', to: 'pages#submit_contact'
  get 'find_on_map', to: 'pages#find_on_map'
  get 'select2_locations', to: 'pages#select2_locations'
  get 'public-move/:id/:some_name', to: 'pages#public_move', as: :public_move
  post 'public-move/:id/:some_name', to: 'pages#submit_public_move'
  get 'public-chat/:id/:some_name', to: 'pages#public_chat', as: :public_chat
  get 'unsubscribe', to: 'pages#unsubscribe'

  get 'sample-error', to: 'pages#sample_error'
  get 'sample-error-in-javascript', to: 'pages#sample_error_in_javascript'
  get 'sample-error-in-javascript-ajax', to: 'pages#sample_error_in_javascript_ajax'
  post 'notify-javascript-error', to: 'pages#notify_javascript_error'
  get 'sample-error-in-sidekiq', to: 'pages#sample_error_in_sidekiq'
  get 'active-chats', to: 'pages#active_chats', as: :active_chats

  get 'sign_in_as', to: 'application#sign_in_as'

  get 'dashboard', to: 'dashboard#index'
  get 'buy-me-a-coffee', to: 'dashboard#buy_me_a_coffee'
  get 'shared-callback', to: 'dashboard#shared_callback'
  get 'resend-confirmation-instructions', to: 'dashboard#resend_confirmation_instructions'
  get 'moves-for-age', to: 'dashboard#moves_for_age', as: :all_moves
  get 'moves-for-age/:age', to: 'dashboard#moves_for_age', as: :moves_for_age
  get 'all-chats', to: 'dashboard#all_chats', as: :all_chats
  post 'search-all-chats', to: 'dashboard#search_all_chats', as: :search_all_chats

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
      patch :ignore
    end
  end

  namespace :admin do
    get :dashboard
    resources :users do
      member do
        delete :destroy_move
        post 'add_to_shared_chats/:chat_id', to: 'users#add_to_shared_chats', as: :add_to_shared_chats
      end
      collection do
        post :search
      end
    end
    resources :chats do
      member do
        patch :featured
      end
    end
    get :reported_messages
    resources :locations
    resources :groups
    resources :notify_users
    resources :email_messages
  end
end
# rubocop:enable Metrics/BlockLength
