class ModsController < ApplicationController
  def index
    @mods = Mod

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

      @mods = @mods.in_category @category
    end

    case params[:sort]
    when 'alpha'
      @mods = @mods.sort_by_alpha
    when 'forum_comments'
      @mods = @mods.sort_by_forum_comments
    when 'downloads'
      @mods = @mods.sort_by_downloads
    else
      @mods = @mods.sort_by_most_recent
    end

    @game_versions = GameVersion.groups.sort_by_newer_to_older
    @categories = Category.order_by_mods_count
  end

  def show
    begin
      @mod = Mod.find params[:id]
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end
end
