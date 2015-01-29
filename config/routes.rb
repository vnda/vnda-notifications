VndaApi::Application.routes.draw do
  root to: 'shops#index'
  resources :shops

  scope path: "/api", format: "json" do
    post '/', :to => "api#schedule"
  end

end
