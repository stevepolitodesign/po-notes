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
  # TODO Replace this with a `plan` model
  validate :user_cannot_create_more_notes_after_reaching_their_notes_limit, on: :create, unless: proc { |note| note.user.nil? || note.user.notes_limit.nil? }

  private

  # TODO Replace this with a `plan` model
  def user_cannot_create_more_notes_after_reaching_their_notes_limit
    if user.notes_limit <= user.notes.count
      errors.add(:user_id, "has reached their note limit")
    end
  end
end
