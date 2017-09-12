Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :receive_texts, :send_texts
  get '/receive_texts/index' => '/receive_texts#index'
  post '/receive_texts/index' => '/receive_texts#index'
end
