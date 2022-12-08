class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_search_params
  before_action :set_notifications

  # サインイン後に遷移するpathを設定
  def after_sign_in_path_for(resource)
    root_path
  end

  # ログアウト後に遷移するpathを設定
  def after_sign_out_path_for(resource)
    new_user_session_path
  end

  private

  def set_search_params
    @q = Room.ransack
  end

  def set_notifications
    @notification = Notification.new
  end
end
