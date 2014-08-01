ActiveAdmin.register Mod do
  permit_params :name, :author_name, :category_id, :author_id,
                :first_version_date, :last_version_date, :github_url, :forum_comments_count,
                :license, :license_url, :official_url, :forum_post_url,
                :description, :summary, :slug,
                assets_attributes: [:id, :video_url, :image,
                                    :sort_order, :_destroy],
                versions_attributes: [:id, :number, :released_at, :sort_order, :_destroy, game_version_ids: []],
                files_attributes: [:id, :name, :attachment, :sort_order,
                                   :mod_version_id, :_destroy]

  index do
    selectable_column
    id_column

    column :name do |mod|
      link_to(mod.name, [mod.category, mod]) +
      link_to(' [Official &#11016;]'.html_safe, mod.official_url)
    end

    column :category do |mod|
      link_to mod.category.name, [mod.category, :mods]
    end

    column :author do |mod|
      if mod.author
        link_to mod.author_name, [:admin, mod.author]
      else
        mod.author_name
      end
    end

    column :github do |mod|
      link_to mod.github_path, mod.github_url
    end

    column :license

    column :forum do |mod|
      link_to "#{mod.forum_comments_count} comments", mod.forum_post_url
    end

    column 'Visits/Down' do |mod|
      "#{mod.visits_count}/#{mod.downloads_count}"
    end

    column :created_at do |mod|
      span distance_of_time_in_words_to_now(mod.created_at), title: mod.created_at
    end

    column :updated_at do |mod|
      span distance_of_time_in_words_to_now(mod.updated_at), title: mod.updated_at
    end

    actions
  end

  filter :name
  filter :author
  filter :author_name

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :name
      f.input :category
      f.input :slug
      f.input :author
      f.input :author_name
      f.input :github_url
      f.input :license
      f.input :license_url
      f.input :official_url
      f.input :forum_post_url
      f.input :forum_comments_count
      f.input :description
      f.input :summary
    end

    f.inputs do
      f.has_many :versions, allow_destroy: true, new_record: true, sortable: :sort_order do |a|
        a.input :number
        a.input :game_versions
        a.input :released_at, as: :datepicker, input_html: { value: (a.object.released_at.strftime('%Y-%m-%d') unless a.object.released_at.nil?) }
      end
    end

    f.inputs do
      f.has_many :files, allow_destroy: true, new_record: true, sortable: :sort_order do |a|
        a.input :name
        a.input :attachment, as: :attachment
        a.input :mod_version
      end
    end

    f.inputs do
      f.has_many :assets, allow_destroy: true, new_record: true, sortable: :sort_order do |a|
        a.input :video_url
        a.input :image, as: :attachment, image: (:thumb unless a.object.video? )
      end
    end

    f.actions
  end


  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end

end
