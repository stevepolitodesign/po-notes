class Note < ApplicationRecord
  belongs_to :user
  acts_as_taggable

  validates :title, presence: true
  
  before_validation :set_default_title

  private
    def set_default_title
      unless self.title 
        self.title = 'Untitled' 
      end
    end

end
