Rails.application.routes.draw do
  devise_for :users,
              path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'register' },
              controllers: { registrations: 'users/registrations' }

  # It's open source so really no much obscurity,
  # but at least it will deter a few automated crawlers
  scope 'potato' do
    ActiveAdmin.routes(self)
    get '/', to: 'admin/dashboard#index'
  end

  resources :users, only: [:show]

  # Routes examples
  #
  # /mods
  # /mods/new
  # /mods/:id
  # /mods/:id/edit
  #
  # /recently-updated-mods
  # /recently-updated-mods/category/:id
  # /most-downloaded-mods
  # /most-downloaded-mods/category/:id
  #
  # /category/:id

  scope '/', as: :alpha, sort: 'alpha' do
    resources :mods, only: :index
    resources :categories, path: 'category', only: [] do
      resources :mods, path: '/', only: :index
    end
  end

  scope '/recently-updated', sort: 'most_recent', as: :most_recent do
    resources :mods, path: '/', only: :index
    resources :categories, path: 'category', only: [] do
      resources :mods, path: '/', only: :index
    end
  end

  # scope '/most-downloaded', sort: 'most_downloaded', as: :downloads do
  #   resources :mods, path: '/', only: :index
  #   resources :categories, path: 'category', only: [] do
  #     resources :mods, path: '/', only: :index
  #   end
  # end

  scope '/most-popular', sort: 'popular', as: :popular do
    resources :mods, path: '/', only: :index
    resources :categories, path: 'category', only: [] do
      resources :mods, path: '/', only: :index
    end
  end

  # scope '/most-forum-comments', sort: 'popular', as: :forum_comments do
  #   resources :mods, path: '/', only: :index
  #   resources :categories, path: 'category', only: [] do
  #     resources :mods, path: '/', only: :index
  #   end
  # end

  resources :mods
  # This one is for the helper
  resources :categories, path: 'category', only: [] do
    resources :mods, path: '/', only: :index
  end

  get '/how-to-submit' => 'static#how_to_submit', as: :how_to_submit_static
  get '/how-to-install' => 'static#how_to_install', as: :how_to_install_static
  get '/how-to-make' => 'static#how_to_make', as: :how_to_make_static

  root to: 'mods#index', sort: 'most_recent'
end
