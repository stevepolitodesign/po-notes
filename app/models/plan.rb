class Plan < ApplicationRecord
  has_many :users, dependent: :restrict_with_exception

  validates :name, uniqueness: true
end
