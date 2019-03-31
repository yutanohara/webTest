class UsersController < ApplicationController
  before_action :basic_auth, except: :signup

  CREATE_FAILED = 'Account creation failed'.freeze
  def signup
    if !validate_user_id(params[:user_id]) || !validate_password(params[:password])
      return render json: {
        message: CREATE_FAILED,
        cause: 'required user_id and password'
      }
    end
    user = User.create(
      user_id: params[:user_id],
      password: params[:password],
      nickname: params[:user_id]
    )
    if user.id.present?
      render json: {
        message: 'Account successfully created',
        user: {
          user_id: user[:user_id],
          nickname: user[:nickname],
        }
      }
    else
      render json: {
        message: CREATE_FAILED,
        cause: 'already same user_id is used'
      }
    end
  end

  def show
    user = User.find_by(id: params[:user_id])
    json = {
      user_id: user[:user_id],
      nickname: user[:nickname]
    }
    json[:comment] = user[:comment] if user[:comment]
    render json: {
      message: 'User details by user_id',
      user: json
    }
  end

  def update
    if !params[:nickname] && !params[:comment]
      return render json: {
        message: 'User updation failed',
        cause: 'required nickname or comment'
      }
    end
    if params[:user_id] && params[:password]
      return render json: {
        message: 'User updation failed',
        cause: 'not updatable user_id and password'
      }
    end
    if params[:user_id] != @user_id
      return render json: {
        message: 'No Permission for Update'
      }
    end
    can_update = true
    user = User.find_by(id: params[:user_id])
    if !params[:nickname]
      user[:nickname] = user[:user_id]
    elsif params[:nickname] > 30
      can_update = false
    end
    if params[:comment] > 100
      can_update = false
    end
    unless can_update
      return render json: {
        message: 'User updation failed',
        cause: 'length error'
      }
    end
    user[:comment] = params[:comment]
    user.save
    render json: {
      message: 'User successfully updated',
      recipe: [
        {
          nickname: user[:nickname],
          comment: user[:comment]
        }
      ]
    }
  end

  def close
    user = User.find_by(user_id: @user_id)
    user.destroy
    render json: {
      message: 'Account and user successfully removed'
    }
  end

  private

  def validate_user_id(user_id)
    return false if user_id < 6 || user_id > 20 || (/\A[a-zA-Z0-9]+\z/ =~ user_id).nil?
    true
  end

  def validate_password(password)
    # 後で修正
    return false if password < 8 || password > 20 || (/\A[a-zA-Z0-9]+\z/ =~ password).nil?
    true
  end

  def basic_auth
    authenticate_or_request_with_http_basic do |user_id, password|
      @user_id = user_id
      @password = password
      if user_id.nil? || password.nil?
        return render json: {
          'message': 'Authentication Faild'
        }
      end
      user = User.find_by(user_id: user_id, password: password)
      unless user
        render json: {
          'message': 'No User found'
        }
      end
    end
  end
end
