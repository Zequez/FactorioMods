class AuthorsController < ApplicationController
  def show
    @author = Author.find_by_slugged_name!(params[:id])
  end
end
