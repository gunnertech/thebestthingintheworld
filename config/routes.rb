Thebestthingintheworld::Application.routes.draw do
  match 'things/compare' => 'things#index', :via => [:get], as: :things_comparision, defaults: {view: 'compare'}
  resources :things do
    member do
      put 'move_up'
    end
  end


  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users
  resources :users
end