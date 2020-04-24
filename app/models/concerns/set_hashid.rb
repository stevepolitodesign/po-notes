module SetHashid
  extend ActiveSupport::Concern

  included do
    # TODO Update `note` to `record`
    before_validation :set_hashid, prepend: true, if: proc { |note| note.hashid.nil? }
  end

  private

  def set_hashid
    self.hashid = SecureRandom.urlsafe_base64(5)
  end
end
