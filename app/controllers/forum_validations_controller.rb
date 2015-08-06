class ForumValidationsController < ApplicationController
  load_and_authorize_resource :forum_validation, except: :update

  def create
    if current_user.forum_validation
      redirect_to current_user.forum_validation
    else
      @forum_validation.save! # server error if it fails, shouldn't happen
      pm_sent =  @forum_validation.send_pm
      flash[:error] = I18n.t('forum_validations.flash.create.pm_error') unless pm_sent
      redirect_to @forum_validation
    end
  end

  def update
    @forum_validation = ForumValidation.find params[:id]
    if @forum_validation.vid == params[:vid]
      if @forum_validation.validated?
        flash[:notice] = I18n.t('forum_validations.flash.update.already_success')
      else
        @forum_validation.associate_user_and_author!
        @forum_validation.user.give_ownership_of_authored!
        flash[:notice] = I18n.t('forum_validations.flash.update.success')
      end
      redirect_to @forum_validation
    else
      wrong_parameters_error
    end
  end

  def show

  end

  def new
    if current_user.forum_validation
      if current_user.forum_validation.validated?
        redirect_to root_url
      else
        redirect_to forum_validation_url(current_user.forum_validation)
      end
    else
      @forum_validation.author = Author.find_for_forum_validation(current_user.name)
    end
  end

  private

  def resource_params
    params
      .require(:forum_validation)
      .permit(:author_id)
      .merge(user_id: (current_user.id if current_user))
  end
end
