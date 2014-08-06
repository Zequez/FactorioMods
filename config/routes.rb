Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)


  scope 'recently-updated-mods', sort: :most_recent, as: :most_recent do
    get '/',                  to: 'mods#index', as: :mods
    get '/:category_id',      to: 'mods#index', as: :category_mods
  end

  scope 'mods', sort: :alpha, as: :alpha do
    get '/',                  to: 'mods#index', as: :mods
    get '/:category_id',      to: 'mods#index', as: :category_mods
  end

  scope 'mods', sort: :alpha do
    get '/',                  to: 'mods#index', as: :mods
    get '/:category_id',      to: 'mods#index', as: :category_mods
    get '/:category_id/:id',  to: 'mods#show',  as: :category_mod
  end

  get '/how-to-install' => 'static#how_to_install', as: :how_to_install_static
  get '/how-to-make' => 'static#how_to_make', as: :how_to_make_static

  root to: 'mods#index', sort: :most_recent
end