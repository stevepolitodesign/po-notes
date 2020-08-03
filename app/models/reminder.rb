include ActionView::Helpers::DateHelper
class Reminder < ApplicationRecord
  include SetHashid
  include SlugCandidates

  belongs_to :user

  default_scope { order(time: :asc) }
  scope :upcoming, -> { where("time >= ?", Time.zone.now) }
  scope :past, -> { where("time < ?", Time.zone.now) }
  scope :unsent, -> { where(sent: nil) }
  scope :ready_to_send, -> { unsent.where("time <= ?", 30.minutes.from_now) }
  scope :pending, -> { where(sent: false) }
  scope :sent, -> { where(sent: true) }
  scope :ready_to_destroy, -> { sent.past }

  validates :body, length: {maximum: 160}
  validates :name, presence: true
  validates :time, presence: true
  validate :time_must_be_over_30_minute_in_the_future, on: :create, unless: proc { |reminder| reminder.time.nil? }
  validate :limit_user_reminders, on: :create, unless: proc { |reminder| reminder.user.nil? || reminder.user.plan.nil? }

  def send_sms
    return if sent? || user.telephone.nil?
    @telephone = user.telephone
    @client = Twilio::REST::Client.new Rails.application.credentials.twilio[:account_sid], Rails.application.credentials.twilio[:auth_token]
    @response = @client.messages.create(
      from: Rails.application.credentials.twilio[:number],
      to:  @telephone,
      body: "Reminder: #{name} start at #{time_ago_in_words(time)} from now."
    )
    update(sent: true)
    @response
  end

  private

  def time_must_be_over_30_minute_in_the_future
    errors.add(:time, "must be over 30 minutes from now") if time <= 30.minutes.from_now
  end

  def limit_user_reminders
    errors.add(:user_id, "has reached their note limit") if user.plan.reminders_limit <= user.reminders.count
  end
end
