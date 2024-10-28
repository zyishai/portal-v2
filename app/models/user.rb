class User < ApplicationRecord
  has_many :active_sessions, dependent: :destroy
  has_many :visits, class_name: "Visitor"
  has_many :events, through: :visits

  CONFIRMATION_TOKEN_EXPIRATION = 10.minutes
  PASSWORD_RESET_TOKEN_EXPIRATION = 10.minutes
  MAILER_FROM_EMAIL = "no-reply@example.com"

  attr_accessor :current_password

  has_secure_password

  before_save :downcase_email
  before_save :downcase_unconfirmed_email

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true, uniqueness: true
  validates :unconfirmed_email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }

  def send_confirmation_email!
    confirmation_token = generate_confirmation_token
    UserMailer.confirmation(self, confirmation_token).deliver_now
  end

  def confirm!
    if unconfirmed_or_reconfirming?
      if unconfirmed_email.present?
        return false unless update(email: unconfirmed_email, unconfirmed_email: nil)
      end
      update_columns(confirmed_at: Time.current)
    else
      false
    end
  end

  def confirmed?
    confirmed_at.present?
  end

  def generate_confirmation_token
    signed_id expires_in: CONFIRMATION_TOKEN_EXPIRATION, purpose: :confirm_email
  end

  def unconfirmed?
    !confirmed?
  end

  def confirmable_email
    if unconfirmed_email.present?
      self.unconfirmed_email
    else
      self.email
    end
  end

  def reconfirming?
    unconfirmed_email.present?
  end

  def unconfirmed_or_reconfirming?
    unconfirmed? || reconfirming?
  end

  def send_password_reset_email!
    password_reset_token = generate_password_reset_token
    UserMailer.password_reset(self, password_reset_token).deliver_now
  end

  def generate_password_reset_token
    signed_id expires_in: PASSWORD_RESET_TOKEN_EXPIRATION, purpose: :reset_password
  end

  def time_on_site
    Visitor.total_time_on_site_for_visitor(visits)
  end

  def average_time_on_site
    Visitor.average_time_on_site_for_visitor(visits)
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def downcase_unconfirmed_email
    return if self.unconfirmed_email.nil?
    self.unconfirmed_email = unconfirmed_email.downcase
  end
end
