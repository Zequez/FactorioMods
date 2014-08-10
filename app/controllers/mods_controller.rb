class ModsController < ApplicationController
  def index
    @mods = Mod

    @mods = @mods.includes([:first_asset, :category, :author, versions: :files])

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


  private

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
