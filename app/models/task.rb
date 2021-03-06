class Task < ApplicationRecord
  include SetHashid
  include ParseTags
  include SlugCandidates

  default_scope { order(updated_at: :desc) }
  acts_as_ordered_taggable

  belongs_to :user
  has_many :task_items, -> { order(position: :asc) }, dependent: :destroy, inverse_of: :task
  accepts_nested_attributes_for :task_items, allow_destroy: true, reject_if: :all_blank

  validate :limit_user_tasks, on: :create, unless: proc { |task| task.user.nil? || task.user.plan.nil? }
  validate :limit_task_items

  private

  def limit_user_tasks
    errors.add(:user_id, "has reached their task limit") if user.plan.tasks_limit <= user.tasks.count
  end

  def limit_task_items
    errors.add(:task, "cannot have more than 50 task items") if task_items.count >= 50
  end
end
