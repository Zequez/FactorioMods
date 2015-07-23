class ModsController < ApplicationController
  load_and_authorize_resource
  
  respond_to :html, :json, only: [:index, :show]

  def index
    @mods = Mod

    @mods = @mods
      .includes([:categories, :authors, :owner, :forum_post, versions: :files])
      .page(params[:page]).per(20)

    

    @sort = params[:sort].to_sym
    case @sort
    when :alpha
      @mods = @mods.sort_by_alpha
    when :popular
      @mods = @mods.sort_by_popular
    when :forum_comments
      @mods = @mods.sort_by_forum_comments
    when :downloads
      @mods = @mods.sort_by_downloads
    when :most_recent
      @mods = @mods.sort_by_most_recent
    else
      @mods = @mods.sort_by_alpha
    end

    unless params[:v].blank?
      @game_version = GameVersion.find_by_number(params[:v])
      if @game_version
        @mods = @mods.filter_by_game_version @game_version
      else
        @mods = []
      end
    end

    unless params[:q].blank?
      @query = params[:q][0..30]
      @mods = @mods.filter_by_search_query(@query)
    end
    
    @uncategorized_mods_total_count = @mods.total_count
    @all_mods_count = Mod.count
    if params[:category_id]
      @category = Category.find_by_slug params[:category_id]
      if @category
        @mods = @mods.filter_by_category @category
      else
        not_found and return
      end
    end

    @game_versions = GameVersion.sort_by_newer_to_older
    @categories = Category.order_by_mods_count.order_by_name
    
    respond_with @mods
  end

  def show
    @mod = Mod.includes(versions: :files).find_by_slug(params[:id])
    not_found unless @mod

    respond_with @mod
  end

  def new
    @mod = Mod.new
    mod_version = @mod.versions.build
    mod_file = mod_version.files.build

    if params[:forum_post_id]
      forum_post = ForumPost.find params[:forum_post_id]
      @mod.name = forum_post.title

      @mod.authors_list = forum_post.author_name
      @mod.forum_url = forum_post.url

      if forum_post.published_at
        mod_version.released_at = forum_post.published_at
      end

      if forum_post.subforum and forum_post.subforum.game_version
        mod_version.game_versions = [forum_post.subforum.game_version]
      end
      # scraper = ForumPostScraper.new forum_post
      # scraper.scrap
      # @mod.description = forum_post.markdown_content
    end

    render_form
  end

  def create
    @mod = Mod.new(current_user.is_admin? ? mod_params_admin : mod_params)
    if @mod.save
      redirect_to mod_url(@mod)
    else
      render_form
    end
  end

  def edit
    @mod = Mod.find params[:id]
    @existing_authors_names = User.pluck(:name)
    render_form
  end

  def update
    @mod = Mod.find params[:id]
    if @mod.update current_user.is_admin? ? mod_params_admin : mod_params
      redirect_to mod_url(@mod)
    else
      render_form
    end
  end

  private

  def render_form
    @existing_authors_names = User.pluck(:name)
    render :new
  end

  def mod_params
    params.require(:mod).permit(:name,
                                :github,
                                :official_url,
                                :forum_url,
                                :forum_subforum_url,
                                :summary,
                                :imgur,
                                :authors_list,
                                category_ids: [],
                                versions_attributes: [
                                  :id,
                                  :number,
                                  :released_at,
                                  :_destroy,
                                  game_version_ids: [],
                                  files_attributes: [
                                    :id,
                                    :attachment,
                                    :name,
                                    :download_url,
                                    :_destroy
                                  ]
                                ])
    .merge(author_id: current_user.id)
  end

  def mod_params_admin
    mod_params.merge params.require(:mod).permit(:author_name, :author_id, :slug)
  end

  # def category
  #   @category ||= if params[:category_id]
  #     begin
  #       @category = Category.find(params[:category_id])
  #     rescue ActiveRecord::RecordNotFound
  #       begin
  #         @mod = Mod.find(params[:category_id])
  #         redirect_to category_mod_url(@mod.category, @mod), status: :moved_permanently
  #       rescue ActiveRecord::RecordNotFound
  #         not_found
  #       end
  #     end

  #     @mods = @mods.filter_by_category @category
  #   end
  # else
  #   nil
  # end
end