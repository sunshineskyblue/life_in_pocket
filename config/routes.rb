Rails.application.routes.draw do
  get 'notifications/index'
  root to: 'top#index'
  resources :top, only: :index

  devise_for(
    # deviseのモデル
    :users,
    # deviseで生成するURLの基準となるパス
    path: 'settings',
    # deviseのコントローラがあるディレクトリ
    module: 'users'
  )

  # deviseにルーティングを追加する
  devise_scope :user do
    get '/login', to: 'users/sessions#new'
    get '/sign_up', to: 'users/registrations#new'
  end

  resources :user_profiles, path: 'settings', only: [] do
    get '/profile', to: 'user_profiles#edit', on: :member
    patch '/profile', to: 'user_profiles#update', on: :member
  end

  resources :rooms, only: %i(index show) do
    post '/create', to: 'rooms#create', on: :collection
    get '/create', to: 'rooms#new', on: :collection
  end

  resources :room_search_forms, only: :index do
    get 'area_search', on: :collection
  end

  resources :reservations do
    get 'registered', on: :member
    get 'completed', on: :collection
  end

  resources :reservation_hosts, path: 'hosts', only: %i(index show update) do
    get 'completed', on: :collection
  end

  resources :notifications, only: :index

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
