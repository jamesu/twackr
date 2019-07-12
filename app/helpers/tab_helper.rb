class TabHelper

	def named(name)
		@name = name
	end

	def titled(title)
		@title = title
	end

	def highlights_on(cond)
		@cond = cond
	end

	def links_to(url)
		@url = url
	end

	def attr_to_ts(list)
		list.map {|k,v| v.nil? ? nil : "#{k}=\"#{Rack::Utils.escape_html(v)}\"" }.compact.join(" ")
	end

	def to_s
		attrs = {:id => "tab_#{@name}"}
		attrs[:class] = 'active' if @cond == true
		attrs[:title] = @title if !@title.nil?
		attrs = attr_to_ts(attrs)
		content = Rack::Utils.escape_html(@name)
		content = "<a href=\"#{Rack::Utils.escape_html(@url)}\" #{attrs}>#{content}</a>" if !@url.nil?
		"<li>#{content}</li>"
	end
end
