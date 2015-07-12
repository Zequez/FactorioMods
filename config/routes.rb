Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  scope 'potato' do
    ActiveAdmin.routes(self)
    get '/', to: 'admin/dashboard#index'
  end

  #
  # /mods
  # /mods/new
  # /mods/:id
  # /mods/:id/edit
  #
  # /recently-updated-mods
  # /recently-updated-mods/tag/:id
  # /most-downloaded-mods
  # /most-downloaded-mods/tag/:id
  #
  # /tag/:id
  #
  # /mods/recently-updated
  # /mods/recently-updated/:category_id
  # /mods/most-downloaded
  # /mods/most-downloaded/:category_id

  resources :categories, path: 'tag', only: [] do
    resources :mods, path: '/', only: :index
  end

  scope '/mods', sort: 'alpha', as: :alpha do
    resources :mods, path: '/', only: :index
  end

  scope '/recently-updated', sort: 'recently-updated', as: :recently_updated do
    resources :mods, path: '/', only: :index
    resources :categories, path: 'tag', only: [] do
      resources :mods, path: '/', only: :index
    end
  end

  scope '/most-downloaded', sort: 'most_downloaded', as: :most_downloaded do
    resources :mods, path: '/', only: :index
    resources :categories, path: 'tag', only: [] do
      resources :mods, path: '/', only: :index
    end
  end

  resources :mods

  get '/how-to-submit' => 'static#how_to_submit', as: :how_to_submit_static
  get '/how-to-install' => 'static#how_to_install', as: :how_to_install_static
  get '/how-to-make' => 'static#how_to_make', as: :how_to_make_static

  root to: 'mods#index', sort: 'most_recent'
end