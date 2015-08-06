class ForumValidationsController < ApplicationController
  def create
    @forum_validation = ForumValidation.new resource_params
    @forum_validation.save! # server error if it fails, shouldn't happen
    pm_sent =  @forum_validation.send_pm
    flash[:error] = I18n.t('forum_validations.flash.create.pm_error') unless pm_sent
    redirect_to @forum_validation
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

  private

  def resource_params
    params.require(:forum_validation).permit(:author_id, :user_id)
  end
end
