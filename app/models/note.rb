class Note < ApplicationRecord
  extend FriendlyId
  friendly_id :hashid, use: :slugged
  default_scope { order(pinned: :asc, updated_at: :desc) }
  belongs_to :user
  acts_as_taggable
  has_paper_trail

  validates :title, presence: true
  validates :body, presence: true
  
  before_validation :set_default_title
  before_create :set_hashid

  private
    def set_default_title
      unless self.title 
        self.title = 'Untitled' 
      end
    end

    def set_hashid
      self.hashid = SecureRandom.hex(5)
    end

end
