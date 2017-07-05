Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :clients
  resources :billing_plans
  resources :subscriptions
  get 'client/subscriptions' => 'clients#subscriptions'
  get 'ConfirmSuscription' => 'subscriptions#execute'
  post 'paypal_webhook' => 'webhooks#paypal_webhook'
  post '/' => 'webhooks#paypal_webhook'
  get 'webhooks' => 'webhooks#index'
  get 'webhook/new' => 'webhooks#create'
  delete 'webhook' => 'webhooks#destroy'
  root :to => "welcome#index"
end
