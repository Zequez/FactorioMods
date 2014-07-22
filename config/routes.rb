Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)


  get 'mods',                               to: 'mods#index', as: :mods
  get 'mods(/:category_id)/sort',           to: 'mods#index', as: :mods_sort,                 params: { sort: :alpha }
  get 'mods(/:category_id)/sort/comments',  to: 'mods#index', as: :mods_sort_forum_comments,  params: { sort: :forum_comments }
  get 'mods(/:category_id)/sort/downloads', to: 'mods#index', as: :mods_sort_downloads,       params: { sort: :downloads }
  get 'mods/:category_id',                  to: 'mods#index', as: :category_mods
  get 'mods/:category_id/:id',              to: 'mods#show',  as: :category_mod

  # resources :mods, only: :index do
  #   namespace :categories
  # end

  # resources :categories, path: '/mods', only: :show do
  #   namespace 'sort' do
  #     get '/',          to: 'mods#index', params: { sort: :alpha }
  #     get '/comments',  to: 'mods#index', params: { sort: :comments }
  #     get '/downloads', to: 'mods#index', params: { sort: :comments }
  #   end

  #   resources :mods, path: '/', only: [:index, :show] do

  #   end
  # end

  root to: 'mods#index'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

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
