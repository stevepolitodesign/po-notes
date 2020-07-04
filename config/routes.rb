Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: 'users/sessions',
    passwords: 'users/passwords',
  }

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
      get "import", to: "import_notes#new"
      post "import", to: "import_notes#create"
      get "export", to: "export_notes#index", defaults: {format: "csv"}
    end
  end

  resources :tasks, except: [:edit] do
    resources :task_items, only: [:create, :update, :destroy]
  end

  resources :reminders, except: [:show]
end
