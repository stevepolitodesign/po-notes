class Plan < ApplicationRecord
  validates :name, uniqueness: true
end
