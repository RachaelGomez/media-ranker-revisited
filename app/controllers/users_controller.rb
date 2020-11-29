# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_login, only: %i[index show]
  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def create
    auth_hash = request.env['omniauth.auth']

    user = User.find_by(uid: auth_hash[:uid], provider: 'github') # params[:provider])

    if user
      # user exists
      flash[:success] = "Existing user #{user.username} is logged in."
    else
      # user doesn't exist yet
      user = User.build_from_github(auth_hash)
      if user.save
        flash[:success] = "Logged in as new user #{user.username}"
      else
        flash[:error] = "Could not create user account #{user.errors.full_messages.join(', ')}"
      end
    end

    session[:user_id] = user.id
    session[:username] = user.username
    redirect_to root_path
    nil
  end

  def destroy
    if session[:user_id]
      session[:user_id] = nil
      flash[:status] = 'Successfully logged out'
      redirect_to root_path
      nil
    else
      flash[:error] = 'Must log in first!'
      redirect_to root_path
    end
  end
end
