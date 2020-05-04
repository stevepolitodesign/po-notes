include ActionView::Helpers::DateHelper
class Reminder < ApplicationRecord
  include SetHashid
  include SlugCandidates

  # TODO Add this to SlugCandidates
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  belongs_to :user

  default_scope { order(time: :asc) }
  scope :upcoming, -> { where("time >= ?", Time.zone.now) }
  scope :past, -> { where("time < ?", Time.zone.now) }
  scope :unsent, -> { where(sent: nil) }
  scope :pending, -> { where(sent: false) }
  scope :ready_to_send, -> { unsent.where("time <= ?", 30.minutes.from_now) }
  scope :sent, -> { where(sent: true) }
  scope :ready_to_destroy, -> { sent.past }

  validates :body, length: {maximum: 160}
  validate :time_must_be_over_30_minute_in_the_future, on: :create, unless: proc { |reminder| reminder.time.nil? }
  validate :time_cannot_be_changed_after_create, on: :update
  validate :limit_user_reminders, on: :create, unless: proc { |reminder| reminder.user.nil? || reminder.user.plan.nil? }

  def send_sms
    return if sent? || user.telephone.nil?
    @telephone = user.telephone
    @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
    @response = @client.messages.create(
      from: ENV["TWILIO_NUMBER"],
      to: ENV["RAILS_ENV"] == "production" ? @telephone : ENV["TWILIO_TEST_NUMBER"],
      body: "Reminder: #{name} start at #{time_ago_in_words(time)} from now."
    )
    # TODO This is not updating the record
    # This is because when it's called, the `time` is less than 30 minutes, and this it's invalid.
    update(sent: true)
    @response
  end

  private

  def time_must_be_over_30_minute_in_the_future
    errors.add(:time, "must be over 30 minutes from now") if time <= 30.minutes.from_now
  end

  def time_cannot_be_changed_after_create
    errors.add(:time, "cannot change once saved") if time_changed?
  end

  def limit_user_reminders
    limit = case user.plan
    when "free"
      25
    else
      25
    end
    errors.add(:user_id, "has reached their note limit") if limit <= user.reminders.count
  end
end
