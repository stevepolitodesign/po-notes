class Note < ApplicationRecord
  default_scope { order(pinned: :asc, updated_at: :desc) }
  belongs_to :user
  acts_as_taggable
  has_paper_trail

  validates :title, presence: true
  validates :body, presence: true
  
  before_validation :set_default_title

  private
    def set_default_title
      unless self.title 
        self.title = 'Untitled' 
      end
    end

end
