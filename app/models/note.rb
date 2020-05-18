class Note < ApplicationRecord
  include SetHashid
  include ParseTags
  include SlugCandidates

  # TODO Add this to SlugCandidates
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  default_scope { order(pinned: :desc, updated_at: :desc) }
  belongs_to :user
  acts_as_ordered_taggable
  has_paper_trail

  validates :body, presence: true
  validate :limit_user_notes, on: :create, unless: proc { |note| note.user.nil? || note.user.plan.nil? }

  private

  def limit_user_notes
    errors.add(:user_id, "has reached their note limit") if user.plan.notes_limit <= user.notes.count
  end
end
