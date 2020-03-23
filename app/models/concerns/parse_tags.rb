module ParseTags
  extend ActiveSupport::Concern

  included do
    before_save :parse_tag_list, unless: proc { |note| note.tag_list.empty? }
  end

  private

  def parse_tag_list
    begin
      tags = JSON.parse(tag_list.to_s)
    rescue
      tags = tag_list
    end
    parsed_tags = []
    tags.each do |tag|
      parsed_tags << tag["value"] unless tag["value"].nil?
    end
    self.tag_list = parsed_tags.empty? ? tag_list : parsed_tags
  end
end
