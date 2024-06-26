Rails.application.routes.draw do
  devise_for :users

  resources :designs do
    member do
      get 'clone'
      get 'print'     # prints design
    end
  end
  resources :sides
  resources :artifacts do
    member do
      get 'copy_props'
    end
  end
  resources :properties

  scope '/manage' do
    resources :users
  end

  root 'badges#new'

  resources :badges do
    member do
      get 'camera'    # takes image
      get 'print'     # prints badge
      get 'generate'  # generate badge
      get 'publish'   # publish to active directory

      patch 'snapshot'  # uploads file
      get 'crop'      # crops picture
      post 'snapshot' # uploads snapshot
    end

    collection  do
      get 'recent'  # show gallery of recent mugshots
      get 'guesswho'
    end
  end

  post 'lookup' => 'badges#lookup', as: :lookup


  get 'printqueue/queue', controller: :printqueue, action: :queue
end
