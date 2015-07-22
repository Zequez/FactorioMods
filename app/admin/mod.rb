ActiveAdmin.register Mod do
  permit_params :name, :category_id, :author_id,
                :first_version_date, :last_version_date, :github, :forum_comments_count,
                :license, :license_url, :official_url, :forum_subforum_url,
                :forum_post_id, :forum_posts_ids,
                :description, :summary, :slug, :imgur, :authors_list,
                assets_attributes: [:id, :image, :sort_order, :_destroy],
                versions_attributes: [:id, :number, :released_at,
                                      :sort_order, :precise_game_versions_string,
                                      :_destroy, game_version_ids: []],
                files_attributes: [:id, :name, :attachment, :sort_order,
                                   :mod_version_id, :_destroy]

  controller do
    def scoped_collection
      Mod.includes(:categories, :owner, :authors, :forum_post)
    end

    def resource
      @mod ||= Mod.includes(versions: [:game_versions]).includes(files: [:mod_version]).find(params[:id])
      if params[:forum_post_id]
        forum_post = ForumPost.find(params[:forum_post_id])
        @mod.forum_post = forum_post
        @mod.forum_posts = [forum_post]
      end
      @mod
    end
  end

  show do |mod|
    h2 link_to mod_path(mod), mod

    attributes_table :name,
                     :slug,
                     :authors_list,
                     :owner,
                     :first_version_date,
                     :last_version_date,
                     :github_url,
                     :official_url,
                     :forum_url,
                     :summary,
                     :imgur_url



    active_admin_comments
  end

  index do
    selectable_column
    id_column

    column :name do |mod|
      link_to(mod.name, mod)
    end

    column :categories do |mod|
      mod.categories.map(&:name).join(', ')
    end

    column :authors do |mod|
      mod.authors.map(&:name).join(', ')
    end

    column :owner

    column :github do |mod|
      link_to mod.github_path, mod.github_url
    end

    column :forum do |mod|
      link_to "#{mod.forum_post.views_count}V / #{mod.forum_post.comments_count}C", [:edit, :admin, mod.forum_post]
    end

    # column 'Visits/Down' do |mod|
    #   "#{mod.visits_count}/#{mod.downloads_count}"
    # end

    column :created_at do |mod|
      span distance_of_time_in_words_to_now(mod.created_at), title: mod.created_at
    end

    column :updated_at do |mod|
      span distance_of_time_in_words_to_now(mod.updated_at), title: mod.updated_at
    end

    column :imgur do |mod|
      link_to mod.imgur, mod.imgur_url if mod.imgur
    end

    column :is_dev

    column :edit do |mod|
      link_to 'EditPublic', edit_mod_url(mod)
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
      f.input :categories
      f.input :slug
      f.input :owner
      f.input :authors_list
      f.input :github_url
      f.input :official_url
      f.input :forum_url
      f.input :forum_subforum_url
      # f.input :forum_post
      # f.input :forum_posts, collection: ForumPost.order('title')
      f.input :imgur
      f.input :is_dev
      f.input :summary, as: :text
    end

    f.actions

    f.inputs do
      game_versions = GameVersion.all
      f.has_many :versions, allow_destroy: true, new_record: true, sortable: :sort_order do |a|
        a.input :number
        a.input :game_versions, collection: game_versions
        a.input :precise_game_versions_string, placeholder: '1.1.3[-1.1.4]'
        a.input :released_at, as: :datepicker, input_html: { value: (a.object.released_at.strftime('%Y-%m-%d') unless a.object.released_at.nil?) }
      end
    end

    f.inputs do
      mod_versions = f.object.versions.all
      f.has_many :files, allow_destroy: true, new_record: true, sortable: :sort_order do |a|
        a.input :name
        a.input :attachment, as: :attachment
        a.input :download_url
        a.input :mod_version, collection: mod_versions
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
