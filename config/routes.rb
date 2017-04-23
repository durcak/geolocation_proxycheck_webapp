Rails.application.routes.draw do
  resources :users do
    collection do
      post :import
      get :geolocate
      get :search
      delete :delete_all
      get :map
      get :show_proxy
      get :check_proxy
      get :visualisation
   end

  end
  root 'users#index'

  # get '/tor' => 'users#tor', as: :tor
  # get '/proxy' => 'users#proxy', as: :proxy
  get '/_ah/health', to: proc { [404, {}, ['']] } 
end
