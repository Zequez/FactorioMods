class API::ModsController < API::APIController
  def show
    @mod = Mod.find_by_info_json_name!(params[:id])
    render json: @mod, serializer: ModSerializer
  end

  def index
    @mods = Mod
      .includes([:categories, :author, versions: :files])
      .sort_by(:alpha)
      .filter_by_search_query(params[:q])
      .filter_by_category(params[:category])
      .filter_by_names(params[:names])
      .filter_by_ids(params[:ids])
      .page(params[:page]).per(50)
    render json: @mods, each_serializer: ModSerializer
  end
end
