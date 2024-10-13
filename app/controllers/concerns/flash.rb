module Flash
  extend ActiveSupport::Concern

  included do
    helper_method :is_root_flash?
    helper_method :is_error?
    helper_method :is_alert?
    helper_method :is_notice?
    helper_method :root_flash
  end

  def is_notice?
    flash.key? :notice
  end

  def is_alert?
    flash.key? :alert
  end

  def is_error?
    flash.key? :error
  end

  def is_root_flash?
    is_error? || is_alert? || is_notice?
  end

  def root_flash
    if is_error?
      flash[:error]
    elsif is_alert?
      alert
    else
      notice
    end
  end
end
