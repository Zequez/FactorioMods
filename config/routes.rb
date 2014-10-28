Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  scope 'potato' do
    ActiveAdmin.routes(self)
    get '/', to: 'admin/dashboard#index'
  end

  # most_recent_mods_url          => 'recently-updated-mods/'
  # most_recent_category_mods_url => 'recently-updated-mods/<category_id>'
  scope 'recently-updated-mods', sort: 'most_recent', as: :most_recent do
    get '/',                  to: 'mods#index', as: :mods
    get '/:category_id',      to: 'mods#index', as: :category_mods
  end

  scope 'mods' do
    get '/new', to: 'mods#new'
    get '/:id/edit', to: 'mods#edit'
    post '/', to: 'mods#create'
    put '/', to: 'mods#update'
  end

  # alpha_mods_url          => 'mods/'
  # alpha_category_mods_url => 'mods/<category_id>'
  scope 'mods', sort: 'alpha', as: :alpha do
    get '/',                  to: 'mods#index', as: :mods
    get '/:category_id',      to: 'mods#index', as: :category_mods
  end

  # mods_url          => 'mods/'
  # category_mods_url => 'mods/<category_id>'
  scope 'mods', sort: 'alpha' do
    get '/',                  to: 'mods#index', as: :mods
    get '/:category_id',      to: 'mods#index', as: :category_mods
  end

  # category_mod_url => 'mods/<category_id>/<mod_id>'
  scope 'mods' do
    get '/:category_id/:id',  to: 'mods#show',  as: :category_mod
  end

  get '/how-to-install' => 'static#how_to_install', as: :how_to_install_static
  get '/how-to-make' => 'static#how_to_make', as: :how_to_make_static

  root to: 'mods#index', sort: 'most_recent'
end