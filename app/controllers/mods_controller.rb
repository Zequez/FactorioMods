class ModsController < ApplicationController
  load_and_authorize_resource

  respond_to :html, :json, only: [:index, :show]

  def index
    @mods = Mod
      .includes([:categories, :authors, :owner, :forum_post, versions: :files])
      .visible
      .sort_by(params[:sort])
      .filter_by_names(params[:names])
      .filter_by_search_query(params[:q])
      .filter_by_game_version(params[:v])
      .filter_by_category(params[:category_id])
      .page(params[:page]).per(20)
      .decorate

    @sort = @mods.sorted_by
    @category = @mods.category
    @game_version = @mods.game_version
    @game_versions = GameVersion.sort_by_newer_to_older
    @categories = Category.order_by_mods_count.order_by_name

    flash.now[:notice] = I18n.t('mods.index.search_notice') if params[:q].present?

    respond_with @mods
  end

  def show
    @mod = Mod.includes(versions: :files).find(params[:id]).decorate
    flash[:notice] = @mod.visibility_notice
    respond_with @mod
  end

  def new
    @mod = Mod.new_for_form(current_user, params[:forum_post_id])
    render_form
  end

  def create
    @mod = Mod.new mod_params
    if @mod.save
      redirect_to mod_url(@mod)
    else
      render_form
    end
  end

  def edit
    @mod = Mod.find params[:id]
    render_form
  end

  def update
    @mod = Mod.find params[:id]
    if @mod.update mod_params
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
    permitted = [
      :name,
      :github,
      :official_url,
      :forum_url,
      :forum_subforum_url,
      :summary,
      :imgur,
      :authors_list,
      :contact,
      :info_json_name,
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
      ]
    ]

    (permitted << :author_id) if can? :set_owner, Mod
    (permitted << :visible) if can? :set_visibility, Mod
    (permitted << :slug) if can? :set_slug, Mod

    permitted_params = params.require(:mod).permit(*permitted)

    if cannot?(:set_owner, Mod) and current_user
      permitted_params.merge! author_id: current_user.id
    end

    if cannot?(:set_visibility, Mod)
      permitted_params.merge! visible: false
    end

    permitted_params
  end
end
