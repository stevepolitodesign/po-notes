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

  validates :body, length: {maximum: 160}
  validate :time_must_be_over_30_minute_in_the_future, unless: proc { |reminder| reminder.time.nil? }
  validate :limit_user_reminders, on: :create, unless: proc { |reminder| reminder.user.nil? || reminder.user.plan.nil? }

  private

  def time_must_be_over_30_minute_in_the_future
    errors.add(:time, "must be over 30 minutes from now") if time <= 30.minutes.from_now
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
