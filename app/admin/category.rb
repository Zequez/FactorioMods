ActiveAdmin.register Category do
  permit_params :name, :icon_class, :slug

  controller do
    def create
      create! { url_for [:admin, Category] }
    end

    def update
      update! { url_for [:admin, Category] }
    end
  end

  index do
    selectable_column
    id_column

    column :name do |category|
      link_to category.name, [category, :mods]
    end
    column :slug do |category|
      url_for [category, :mods]
    end
    column :icon_class

    actions
  end


  form do |f|
    f.inputs do
      f.input :name
      unless f.object.slug.blank?
        f.input :slug
      end
      f.input :icon_class
    end

    f.actions
  end
end
