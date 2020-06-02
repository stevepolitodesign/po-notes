module SlugCandidates
  extend ActiveSupport::Concern
  
  included do
    extend FriendlyId
    friendly_id :slug_candidates, use: :slugged

    private

    def slug_candidates
      [:hashid, [:hashid, :user_id]]
    end
  end
end
