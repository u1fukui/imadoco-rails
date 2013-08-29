class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # 例外ハンドル
  rescue_from Exception, :with => :render_500


  # 404エラーページの表示
  #
  # === パラメータ:
  # execption
  #
  # === 返り値:
  # 404ページ
  #
  def render_404(exception = nil)
    if exception
      logger.info "Rendering 404 with exception: #{exception.message}"
    end

    render :template => "errors/error_404", :status => 404, :content_type => 'text/html'
  end


  # 500エラーページの表示
  #
  # === パラメータ:
  # exception
  #
  # === 返り値:
  # 500ページ
  #
  def render_500(exception = nil)
    if exception
      logger.info "Rendering 500 with exception: #{exception.message}"
    end

    render :template => "errors/error_500", :status => 500, :content_type => 'text/html'
  end

  # 指定した端末にpush通信を送る
  #
  # === パラメータ:
  # device_id::
  #   Push通知を送るデバイスのトークン
  # notification_id::
  #   通知識別ID
  #
  # === 返り値:
  # なし
  #
  def push_notification(device_id, notification_id)
    logger.info "push notification!!!"

    notification = Houston::Notification.new(device: device_id)
    notification.alert = "相手からの反応がありました"

    # Notifications can also change the badge count, have a custom sound, indicate available Newsstand content, or pass along arbitrary data.
    notification.badge = 1
    notification.sound = "sosumi.aiff"
    notification.content_available = true
    notification.custom_data = {notification_id: notification_id}

    # And... sent! That's all it takes.
    Imadoco::Application.config.apn.push(notification)
  end

end
