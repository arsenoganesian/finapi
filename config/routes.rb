Rails.application.routes.draw do
  resources :auth_tokens, only: [ :create ]
  resources :users, only: [ :create ]
  resource :balance, only: [ :show, :update ], controller: :balances
  resources :transfers, only: [ :create ]
end
