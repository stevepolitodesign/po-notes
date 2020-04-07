class Task < ApplicationRecord
  include SetHashid
  include ParseTags
  include SlugCandidates

  # TODO Add this to SlugCandidates
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  default_scope { order(updated_at: :desc) }
  acts_as_ordered_taggable

  belongs_to :user
  has_many :task_items, -> { order(position: :asc) }, dependent: :destroy, inverse_of: :task
  accepts_nested_attributes_for :task_items, allow_destroy: true, reject_if: :all_blank

  # TODO Replace this with a `plan` model
  validate :user_cannot_create_more_notes_after_reaching_their_tasks_limit, on: :create, unless: proc { |task| task.user.nil? || task.user.tasks_limit.nil? }
  validate :limit_task_items

  private

  # TODO Replace this with a `plan` model
  def user_cannot_create_more_notes_after_reaching_their_tasks_limit
    if user.tasks_limit <= user.tasks.count
      errors.add(:user_id, "has reached their task limit")
    end
  end

  def limit_task_items
    errors.add(:task, "cannot have more than 50 task items") if task_items.count >= 50
  end
end
