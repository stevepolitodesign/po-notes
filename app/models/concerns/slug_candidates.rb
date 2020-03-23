module SlugCandidates
  extend ActiveSupport::Concern

  included do
    private

    def slug_candidates
      [:hashid, [:hashid, :user_id]]
    end
  end
end
