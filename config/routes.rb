Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  scope 'potato' do
    ActiveAdmin.routes(self)
    get '/', to: 'admin/dashboard#index'
  end

  # / == /mods/recently-updated
  #
  # /mods/new
  # 
  # /mods
  # /mods/:category_id
  # /mods/:category_id/:id
  # /mods/:category_id/:id/edit
  #
  # /mods/recently-updated
  # /mods/recently-updated/:category_id
  # /mods/most-downloaded
  # /mods/most-downloaded/:category_id

  def category_scope
    resources :categories, path: '/', only: [] do
      yield
    end
  end

  def sort_scope(name, path = nil, as_name = false)
    scope path, sort: name.to_s, as: (name if as_name) do
      yield
    end
  end

  def new_sorting_section(name, path = nil, as_name = false)
    sort_scope(name, path, as_name) do
      resources :mods, path: '/', only: :index
      category_scope do
        resources :mods, path: '/', only: :index
      end
    end
  end

  scope 'mods' do
    resources :mods, path: '/', except: [:index, :show, :edit, :update]

    new_sorting_section(:most_recent, 'recently-updated', true)
    new_sorting_section(:alpha, nil, true) # This is to generate the helper URL
    new_sorting_section(:alpha) # The default sorting

    category_scope do
      resources :mods, path: '/', only: [:show, :edit, :update]
    end
  end

  get '/how-to-install' => 'static#how_to_install', as: :how_to_install_static
  get '/how-to-make' => 'static#how_to_make', as: :how_to_make_static

  root to: 'mods#index', sort: 'most_recent'
end