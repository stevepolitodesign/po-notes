Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root "pages#dashboard", as: :authenticated_root
  end
  root "pages#home"

  resources :notes do
    member do
      get "versions", to: "notes#versions", as: "versions"
      get "versions/:version_id", to: "notes#version", as: "version"
      post "versions/:version_id", to: "notes#revert", as: "revert"
      post "restore", to: "notes#restore", as: "restore"
    end
    collection do
      get "deleted_notes", to: "notes#deleted", as: "deleted"
    end
  end

  resources :tasks, except: [:edit] do
    resources :task_items, only: [:create, :update, :destroy]
  end
end
