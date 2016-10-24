# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do

  devise_for :developers

  root 'welcome#index'

  namespace :api do
    namespace :v1 do
      get '/' => 'api#index'
      get 'stations' => 'api#stations'
      get 'trains' => 'api#trains'
    end
  end

end
