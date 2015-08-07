class BookmarksController < ApplicationController
  before_filter :find_bookmark, only: :destroy
  load_and_authorize_resource :bookmark, through: :current_user

  def index
    @mods = current_user
      .bookmarked_mods
      .includes([:categories, :author, :owner, :forum_post, versions: :files])
      .decorate
  end

  def create
    if @bookmark.save
      render nothing: true, status: :ok
    else
      render nothing: true, status: :bad_request
    end
  end

  def destroy
    @bookmark.destroy!
    render nothing: true, status: :ok
  end

  private

  def find_bookmark
    @bookmark = Bookmark.find_by! bookmark_params
  end

  def bookmark_params
    params.require(:bookmark).permit(:mod_id).merge(user_id: current_user.id)
  end
end
