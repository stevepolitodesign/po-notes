# TODO Limit the amount of task items a task can have.
class Task < ApplicationRecord
  include SetHashid
  include ParseTags
  include SlugCandidates

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  default_scope { order(updated_at: :desc) }
  acts_as_ordered_taggable

  belongs_to :user
  has_many :task_items, -> { order(position: :asc) }, dependent: :destroy

  validate :user_cannot_create_more_notes_after_reaching_their_tasks_limit, on: :create, unless: proc { |task| task.user.nil? || task.user.tasks_limit.nil? }

  private

  def user_cannot_create_more_notes_after_reaching_their_tasks_limit
    if user.tasks_limit <= user.tasks.count
      errors.add(:user_id, "has reached their task limit")
    end
  end
end
