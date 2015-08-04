class API::APIController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  after_filter :set_access_control_headers

  def not_found
    render json: { message: 'Not Found' }, status: :not_found
  end

  def root
    render json: JSON.pretty_generate({
      'mods_url' =>           doc_url(:mods, 'names,ids,page,sort,category,author,q=query'),
      'mod_url' =>            doc_url(:mod, :mod),
      'categories_url' =>     doc_url(:categories),
      'category_url' =>       doc_url(:category, :category),
      'category_mods_url' =>  doc_url(:category_mods, :category, 'page'),
      'authors_url' =>        doc_url(:authors),
      'author_url' =>         doc_url(:author, :author),
      'author_mods_url' =>    doc_url(:author_mods, :author),
      'user_bookmarks_url' => doc_url(:user_bookmarks, :user)
    })
  end

  def doc_url(type, *params)
    args = params.select{|p| p.is_a? Symbol}
    params = (params - args).first
    args.map!{|a| "{#{a}}"}
    url = send(:"api_#{type}_url", *args).gsub('%7B', '{').gsub('%7D', '}')
    params ? url + "{?#{params}}" : url
  end

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = 'http://' + Rails.application.routes.default_url_options[:host]
  end
end
