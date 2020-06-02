module SetHashid
  extend ActiveSupport::Concern

  included do
    before_validation :set_hashid, prepend: true, if: proc { |record| record.hashid.nil? }
  end

  private

  def set_hashid
    self.hashid = SecureRandom.urlsafe_base64(5)
  end
end
