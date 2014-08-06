class ModsController < ApplicationController
  def index
    @mods = Mod

    @mods = @mods.includes([:first_asset, :category, :author, versions: :files])

    if params[:category_id]
      begin
        @category = Category.find(params[:category_id])
      rescue ActiveRecord::RecordNotFound
        begin
          @mod = Mod.find(params[:category_id])
          redirect_to category_mod_url(@mod.category, @mod), status: :moved_permanently
        rescue ActiveRecord::RecordNotFound
          not_found
        end
      end

      @mods = @mods.filter_by_category @category
    end

    @sort = params[:sort]
    case @sort
    when :alpha
      @mods = @mods.sort_by_alpha
    when :forum_comments
      @mods = @mods.sort_by_forum_comments
    when 'downloads'
      @mods = @mods.sort_by_downloads
    else
      @mods = @mods.sort_by_most_recent
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
    begin
      @mod = Mod.includes(versions: :files).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end
end
