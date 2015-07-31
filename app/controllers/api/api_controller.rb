class API::APIController < ActionController::API
  def root
    render json: {
      'mods_url' => 'http://api.factoriomods.com/mods{?q=query,names,page,sort,category,category_id,author,ids}'.html_safe
    }
  end
end
