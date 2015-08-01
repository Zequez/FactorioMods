class API::CategoriesController < API::APIController
  def show
    render json: Category.find(params[:id])
  end

  def index
    render json: Category.all
  end
end
