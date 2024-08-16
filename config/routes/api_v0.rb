# frozen_string_literal: true

api_only_routes = %i[index show create update destroy]

namespace :api do
  namespace :v0 do
    get 'api_status', to: 'example#index'

    scope :auth do
      post :signup, to: 'auth#signup'
      post :signin, to: 'auth#signin'
      post :refresh, to: 'auth#refresh'
    end

    resources :accounts, only: api_only_routes
    resources :categories, only: api_only_routes
  end
end
