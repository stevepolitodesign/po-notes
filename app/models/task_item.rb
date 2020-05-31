
class TaskItem < ApplicationRecord
  belongs_to :task
  acts_as_list scope: :task
  scope :complete, -> { where(complete: true) }
end
