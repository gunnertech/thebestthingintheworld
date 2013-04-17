Thebestthingintheworld::Application.routes.draw do
  resources :assigned_things

  match 'things/compare' => 'things#index', :via => [:get], as: :things_comparision, defaults: {view: 'compare'}
  match 'users/:user_id/assigned_things/compare' => 'assigned_things#index', :via => [:get], as: :user_assigned_things_comparision, defaults: {view: 'compare'}
  match 'activity' => 'versions#index', :via => [:get], as: :activity
  
  resources :things

  authenticated :user do
    root :to => 'assigned_things#index', view: 'compare', user_id: "me"
  end
  root :to => "things#index"
  
  devise_for :users
  resources :users do
    member do
      get 'oauth'
      get 'twitter_oauth'
    end
    
    resources :assigned_things do
      member do
        put 'move_up'
      end
    end
  end
end