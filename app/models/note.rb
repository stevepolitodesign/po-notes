class Note < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged
  default_scope { order(pinned: :desc, updated_at: :desc) }
  belongs_to :user
  acts_as_ordered_taggable
  has_paper_trail

  validates :title, presence: true
  validates :body, presence: true
  validate :user_cannot_create_more_notes_after_reaching_their_notes_limit, on: :create, unless: Proc.new{ |note| note.user.nil? or note.user.notes_limit.nil? }
  
  before_validation :set_default_title, if: Proc.new{ |note| note.title.nil? }
  before_validation :set_hashid, prepend: true, if: Proc.new{ |note| note.hashid.nil? }
  before_save :parse_tag_list, unless: Proc.new{ |note| note.tag_list.empty? }

  private
    def set_default_title
        self.title = 'Untitled'
    end
    
    def set_hashid
      self.hashid = SecureRandom.urlsafe_base64(5)
    end

    def slug_candidates
      [:hashid, [:hashid, :user_id]]
    end

    def parse_tag_list
      begin
        tags = JSON.parse(self.tag_list.to_s)          
      rescue => exception
        tags = self.tag_list
      end
      parsed_tags = []
      tags.each do |tag|
        parsed_tags << tag["value"] unless tag["value"] == nil
      end
      self.tag_list = parsed_tags.empty? ? self.tag_list : parsed_tags
    end

    def user_cannot_create_more_notes_after_reaching_their_notes_limit
        if self.user.notes_limit <= self.user.notes.count       
          errors.add(:user_id, 'has reached their note limit') 
        end
    end

end
