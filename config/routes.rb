Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resource :messages do
    collection do
      post 'reply'
      post 'send_sms'
    end
  end
end
