module ApplicationHelper
  def markdown(text)
    renderer = Redcarpet::Render::HTML.new(filter_html: true, with_toc_data: true, hard_wrap: true, prettify: true)
    Redcarpet::Markdown.new(renderer, autolink: true, tables: true, no_intra_emphasis: true, fenced_code_blocks: true, strikethrough: true, superscript: true, underline: true, highlight: true, quote: true).render(text).html_safe
  end

  def gravatar_url(email)
    hash = Digest::MD5.hexdigest(email)
    image_src = "https://www.gravatar.com/avatar/#{hash}"
  end
end
