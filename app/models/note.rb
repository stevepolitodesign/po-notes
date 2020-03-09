class Note < ApplicationRecord
  extend FriendlyId
  friendly_id :hashid, use: :slugged
  default_scope { order(pinned: :desc, updated_at: :desc) }
  belongs_to :user
  acts_as_ordered_taggable
  has_paper_trail

  validates :title, presence: true
  validates :body, presence: true
  validate :user_cannot_create_more_notes_after_reaching_their_notes_limit, on: :create
  
  before_validation :set_default_title
  before_create :set_hashid
  before_save :parse_tag_list

  private
    def set_default_title
        self.title = 'Untitled' if self.title.nil?
    end
    
    def set_hashid
      self.hashid = SecureRandom.urlsafe_base64(5)
    end

    def parse_tag_list
      unless self.tag_list.empty?
        begin
          tags = JSON.parse(self.tag_list.to_s)          
        rescue => exception
          tags = self.tag_list
        end
        unless tags.empty? 
          parsed_tags = []
          tags.each do |tag|
            parsed_tags << tag["value"] unless tag["value"] == nil
          end
          self.tag_list = parsed_tags.empty? ? self.tag_list : parsed_tags
        end        
      end
    end

    def user_cannot_create_more_notes_after_reaching_their_notes_limit
      unless self.user.nil? or self.user.notes_limit.nil?
          if self.user.notes_limit <= self.user.notes.count       
            errors.add(:user_id, 'has reached their note limit') 
          end
      end
    end

end
