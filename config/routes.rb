GridClient::Application.routes.draw do
  resources :queries do
    member do
      get 'result'
    end
  end
  resources :roles
  resources :users
  resources :auth_service_urls
  resources :sessions
  
  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  get "sign_up" => "users#new", :as => "sign_up"
  get "roles" => "roles#index", :as => "root_roles"
  get "role/assign" => "roles#assign", :to => "role/assign"
  post "role/assign" => "roles#form", :as => "role/assign"
  get "role/update" => "roles#assign", :as => "role/assign"
  
  get "services/data" => "services#data", :as => "services/data"
  get "services/analytical" => "services#analytical", :as => "services/analytical"
  get "services/view" => "services#view", :as => "services"
  get "services/search" => "services#search", :as => "/services/search"
  post "services/view" => "services#view", :as => "services/view"
  
  get "query" => "queries#index", :as => "query/index"
  get "queries/new" => "queries#new", :as => "queries/new"
  get "queries/object" => "queries#create", :as => "query/object"
  get "queries/params" => "queries#new", :as => "query/params"
  post "queries/create" => "queries#create", :as => "query/create"
  get "query/predicate" => "queries#predicate", :as => "query/predicate"
  get "query/xml" => "queries#xml", :as => "query/xml"
  get "query/xmlResult" => "queries#xmlResult", :as => "query/xmlResult"
  
  root :to => "users#new"
end