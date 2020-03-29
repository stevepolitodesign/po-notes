Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root "pages#dashboard", as: :authenticated_root
  end
  root "pages#home"

  resources :notes
  get "/notes/:id/versions", to: "notes#versions", as: "note_versions"
  get "/notes/:id/versions/:version_id", to: "notes#version", as: "note_version"
  post "/notes/:id/versions/:version_id", to: "notes#revert", as: "note_revert"
  get "/deleted_notes", to: "notes#deleted", as: "deleted_notes"
  post "/notes/:id/restore", to: "notes#restore", as: "restore_note"

  resources :tasks do
    resources :task_items, only: [:create, :update, :destroy]
  end
end
