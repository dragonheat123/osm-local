class AccountsController < ApplicationController
  include SessionMethods
  include UserMethods

  layout "site"

  before_action :authorize_web
  before_action :set_locale

  authorize_resource :class => false

  before_action :check_database_readable
  before_action :check_database_writable, :only => [:update]

  allow_thirdparty_images :only => [:edit, :update]
  allow_social_login :only => [:edit, :update]

  def edit
    @tokens = current_user.oauth_tokens.authorized

    if errors = session.delete(:user_errors)
      errors.each do |attribute, error|
        current_user.errors.add(attribute, error)
      end
    end
    @title = t ".title"
  end

  def update
    @tokens = current_user.oauth_tokens.authorized

    user_params = params.require(:user).permit(:display_name, :new_email, :pass_crypt, :pass_crypt_confirmation, :auth_provider)

    if params[:user][:auth_provider].blank? ||
       (params[:user][:auth_provider] == current_user.auth_provider &&
        params[:user][:auth_uid] == current_user.auth_uid)
      update_user(current_user, user_params)
      if current_user.errors.count.zero?
        redirect_to edit_account_path
      else
        render :edit
      end
    else
      session[:new_user_settings] = user_params.to_h
      redirect_to auth_url(params[:user][:auth_provider], params[:user][:auth_uid]), :status => :temporary_redirect
    end
  end

  def destroy
    if current_user.deletion_allowed?
      current_user.soft_destroy!

      session.delete(:user)
      session_expires_automatically

      flash[:notice] = t ".success"
      redirect_to root_path
    else
      head :bad_request
    end
  end
end