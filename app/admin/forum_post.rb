ActiveAdmin.register ForumPost do
  extend ActiveAdmin::ViewsHelper

  config.sort_order = "last_post_at_desc"

  permit_params :title, :author_name, :post_number, :url,
                :published_at, :edited_at, :last_post_at,
                :comments_count, :views_count,
                :title_changed, :not_a_mod, :mod_id
  controller do
    def scoped_collection
      ForumPost.includes(:mod, :subforum)
    end
  end

  collection_action :scrap, method: :post do
    manager = Scraper::SubforumManager.new Subforum.for_scraping
    ForumPost.transaction do
      manager.run
    end
    render json: {}
  end

  member_action :remove_title_changed, method: :put do
    resource.title_changed = !resource.title_changed
    resource.save!
    render json: {}
  end

  member_action :toggle_not_a_mod, method: :put do
    resource.not_a_mod = !resource.not_a_mod
    resource.save!
    render json: {}
  end

  action_item :scrap do
    link_to icon('spin') + ' Scrap',
            [:scrap, :admin, :forum_posts],
            id: 'scrap-forum-posts',
            remote: true,
            method: :post,
            'data-type' => :json
  end

  scope :for_mod_update
  scope :for_mod_creation

  filter :title
  filter :post_number
  filter :published_at
  filter :last_post_at
  filter :comments_count
  filter :views_count
  filter :title_changed
  filter :not_a_mod

  index do
    column(:subforum) { |p| link_to(p.subforum.name, [:edit, :admin, p.subforum]) if p.subforum }

    column :post_number, sortable: :post_number do |post|
      link_to post.post_number, post.url
    end

    column :title, sortable: :title do |post|
      link_to post.title, post.url
    end

    [:published_at, :last_post_at, :created_at, :updated_at].each do |time_column|
      column time_column, sortable: time_column do |post|
        span distance_of_time_in_words_to_now(post[time_column]), title: post[time_column]
      end
    end

    column :comments_count
    column :views_count

    column :mod do |post|
      if post.mod
        link_to post.mod.name, [:edit, post.mod]
      else
        link_to 'Create', [:new, :mod, forum_post_id: post.id]
      end
    end

    column :title_changed do |post|
      toggler_status_tag remove_title_changed_admin_forum_post_path(post), post.title_changed
    end

    column :not_a_mod do |post|
      toggler_status_tag toggle_not_a_mod_admin_forum_post_path(post), post.not_a_mod
    end

    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :title
      f.input :author_name
      f.input :post_number
      f.input :url
      f.input :published_at
      f.input :edited_at
      f.input :last_post_at
      f.input :comments_count
      f.input :views_count
      f.input :title_changed
      f.input :not_a_mod
      f.input :mod
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

  # collection_action
end
