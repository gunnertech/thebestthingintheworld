Thebestthingintheworld::Application.routes.draw do
  match 'things/compare' => 'things#index', :via => [:get], as: :things_comparision, defaults: {view: 'compare'}
  match 'activity' => 'versions#index', :via => [:get], as: :activity
  
  resources :things do
    member do
      put 'move_up'
    end
  end


  authenticated :user do
    root :to => 'things#index', view: 'compare'
  end
  root :to => "things#index", view: 'compare'
  
  devise_for :users
  resources :users
end