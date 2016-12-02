module Jekyll
  class PopularTags < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
    end

    def render(context)
      tags = context.registers[:site].tags
      sorted = tags.sort_by { |t,posts| -posts.count }

      html = ""
      sorted[0..2].each do |t, posts|
        html << "<div class='tags'><a href='/tags/#{t.gsub('/', '-')}'>#{t} (#{posts.count})</a></div>"
      end

      html
    end
  end
end

Liquid::Template.register_tag('popular_tags', Jekyll::PopularTags)
