class UsersController < ApplicationController
  def show
    @user = User.where(slug: params[:id]).first
    @mods = @user ? @user.mods : Mod.where(author_name: params[:id])
    @name = @user ? @user.name : params[:id]
  end
end