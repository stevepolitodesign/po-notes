class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable, :confirmable

  has_many :notes, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :reminders, dependent: :destroy
  belongs_to :plan

  before_validation :assign_default_plan, on: :create, if: proc { |user| user.plan.nil? }

  validates :time_zone, inclusion: {in: ActiveSupport::TimeZone.all.map { |tz| tz.name }}
  validates :telephone, phone: {possible: true, allow_blank: true}
  validates :plan, presence: true

  private

  def assign_default_plan
    @plan = Plan.find_or_create_by(name: "Free")
    self.plan = @plan
  end
end
