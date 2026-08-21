
Faultline::Engine.routes.draw do
  resources :logged_exceptions do
    collection do
      post :clear
      match :query, via: %i[get post]
      post :destroy_all
      get :feed
    end
  end

  root :to => 'logged_exceptions#index'
end
