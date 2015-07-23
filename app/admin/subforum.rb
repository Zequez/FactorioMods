ActiveAdmin.register Subforum do
  config.filters = false
  permit_params :url, :name, :game_version_id, :scrap, :number

  before_save do |subforum|
    subforum.scrap_itself
  end

  controller do
    def scoped_collection
      Subforum.includes(:game_version)
    end
  end

  index do
    column :id
    column :number
    column :name
    column(:url){ |s| link_to s.url, s.url }
    column(:game_version){ |s| s.game_version.number }
    column :scrap
    actions
  end

  form do |f|
    f.inputs do
      f.input :url
      f.input :game_version
      f.input :scrap
    end

    f.actions
  end
end