Mjoff::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
	root 'round#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase
	get 'user' => 'user#entry'
	get "user/auth" => "user#auth"
	get "user/callback" => "user#callback"
	get 'user/complete' => 'user#complete'
	get 'user/register' => 'user#edit'
	get 'user/:screen_name' => 'user#edit'
	post 'user/:screen_name' => 'user#update'
	get 'user/failed' => 'user#failed'
	
	get 'tweet/confirm/:id' => 'tweet#confirm'
	post 'tweet/:id' => 'tweet#update'
	
	get 'admin/enter' => 'admin#userlist'
	post 'admin/enter' => 'admin#enter'
	
	get 'record/:screen_name' => 'record#user'
	get 'record/:screen_name/:open_time' => 'record#user'
	get "record/detail/:open_time/:round_id" => "record#show"

	get 'ranking' => "ranking#index"
	get 'ranking/:open_time' => redirect("/ranking/total/%{open_time}")
	get 'ranking/total/:open_time' => 'ranking#total'
	
  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
	get "round" => "round#index"
	get "round/new" => "round#new"
	post "round" => "round#create"
	delete "round/:id" => "round#destroy"

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
