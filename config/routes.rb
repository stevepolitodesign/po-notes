Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  authenticated :user do
    root 'pages#dashboard', as: :authenticated_root
  end
  
  root "pages#home"
  resources :notes 
end
