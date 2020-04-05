# TODO Consider making a task_item reminderable
class TaskItem < ApplicationRecord
  belongs_to :task
  acts_as_list scope: :task
end
