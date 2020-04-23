class User < ApplicationRecord
  # Active Record caches attributes which causes problems when removing columns. Be sure to ignore the column:
  # TODO Remove once deployed
  self.ignored_columns = ["notes_limit"]
  self.ignored_columns = ["tasks_limit"]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable, :confirmable

  has_many :notes, dependent: :destroy
  has_many :tasks, dependent: :destroy

  enum plan: [:free]
end
