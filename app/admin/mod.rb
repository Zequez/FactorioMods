ActiveAdmin.register Mod do
  permit_params :name, :category_id, :owner_id,
                :first_version_date, :last_version_date, :github, :forum_comments_count,
                :license, :license_url, :official_url, :forum_subforum_url,
                :forum_post_id, :forum_posts_ids,
                :description, :summary, :slug, :imgur, :author_name,
                assets_attributes: [:id, :image, :sort_order, :_destroy],
                versions_attributes: [:id, :number, :released_at,
                                      :sort_order, :precise_game_versions_string,
                                      :_destroy, game_version_ids: []],
                files_attributes: [:id, :name, :attachment, :sort_order,
                                   :mod_version_id, :_destroy]

  controller do
    def scoped_collection
      Mod.includes(:categories, :owner, :author, :forum_post)
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

  scope :without_info_json_name

  show do |mod|
    h2 link_to mod_path(mod), mod

    attributes_table :name,
                     :slug,
                     :author_name,
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

    column :info_json_name

    column :categories do |mod|
      mod.categories.map(&:name).join(', ')
    end

    column :author do |mod|
      link_to mod.author.name, mod.author if mod.author
    end

    column :owner

    column :github do |mod|
      link_to mod.github_path, mod.github_url
    end

    column :forum do |mod|
      if mod.forum_post
        link_to "#{mod.forum_post.views_count}V / #{mod.forum_post.comments_count}C", [:edit, :admin, mod.forum_post]
      end
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
  filter :info_json_name
  filter :owner
  filter :author_name

  form{ |f| } # Use the public editor, it's a waste to maintain 2 editors
end
