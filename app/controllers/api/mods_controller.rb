class API::ModsController < API::APIController
  def show
    @mod = Mod.first
    render json: @mod, serializer: ModSerializer
  end

  def index
    @mods = Mod.sort_by(:alpha)
    render json: @mods, each_serializer: ModSerializer
  end
end
