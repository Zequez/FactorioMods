class ModsController < ApplicationController
  load_and_authorize_resource

  def index
    @mods = Mod

    @mods = @mods.includes([:category, :author, versions: :files])

    if params[:category_id]
      @category = Category.find_by_slug params[:category_id]
      if @category
        @mods = @mods.filter_by_category @category
      else
        @mod = Mod.find_by_slug(params[:category_id])
        if @mod
          redirect_to category_mod_url(@mod.category, @mod), status: :moved_permanently
        else
          not_found
        end
      end
    end

    @sort = params[:sort].to_sym
    case @sort
    when :alpha
      @mods = @mods.sort_by_alpha
    when :forum_comments
      @mods = @mods.sort_by_forum_comments
    when 'downloads'
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
      # Search stuff
    end

    @game_versions = GameVersion.sort_by_newer_to_older
    @categories = Category.order_by_mods_count
    # TODO: latest_files
  end

  def show
    @mod = Mod.includes(versions: :files).find_by_slug(params[:id])
    if @mod
      @category = Category.find_by_slug params[:category_id]
      if @category and @mod.category == @category
        # Do nothing, everything is alright
      else
        redirect_to category_mod_url(@mod.category, @mod), status: :moved_permanently
      end
    else
      not_found
    end
  end

  def new
    @mod = Mod.new
  end

  def create
    @mod = Mod.new(current_user.is_admin? ? mod_params_admin : mod_params)
    if @mod.save
      redirect_to category_mod_url(@mod.category, @mod)
    else
      render :new
    end
  end

  def edit
    @mod = Mod.find params[:id]
    render :new
  end

  def update
    @mod = Mod.find params[:id]
    if @mod.update current_user.is_admin? ? mod_params_admin : mod_params
      redirect_to category_mod_url(@mod.category, @mod)
    else
      render :new
    end
  end

  private

  def mod_params
    params.require(:mod).permit(:name,
                                :category_id,
                                :github,
                                :forum_url,
                                :description,
                                :summary,
                                :media_links_string, 
                                versions_attributes: [
                                  :number,
                                  :released_at,
                                  game_version_ids: [],
                                  files_attributes: [
                                    :attachment,
                                    :name
                                  ]
                                ])
    .merge(author_id: current_user.id)
  end

  def mod_params_admin
    mod_params.merge params.require(:mod).permit(:author_name)
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