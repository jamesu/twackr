module ApplicationHelper

  def simple_tag(type, content, attrs={})
    is_unescaped = attrs[:unescaped]
    attrs = attr_to_ts(attrs)
    if content.nil?
      "<#{type} #{attrs}/>"
    else
      if !is_unescaped
        content = Rack::Utils.escape_html(content)
      end
      "<#{type} #{attrs}>#{content}</#{type}>"
    end
  end

  def error_status(error, message, args={}, continue_ok=true)
    flash[:error] = error
    flash[:message] = t(message, args)
    
    return unless (error and continue_ok)
    
    # Construct a reply with a relevant error
    respond_to do |format|
        format.html { redirect_back_or_default('/') }
        format.js { render(:update) do |page| 
                      page.replace_html('statusBar', h(flash[:message]))
                      page.show 'statusBar'
                    end }
    end
  end
  
  def set_time_zone
    #Time.zone = @logged_user.timezone if @logged_user
    @time_now = Time.now#Time.zone.now
    @date_now = @time_now.to_date
  end
  
  def find_project_opt
    @project = @logged_user.projects_dataset.where(:id => params[:project_id]).first
  end

  def load_session
    login_required
    set_time_zone
  end



  def status_bar
    flash_error = @flash_error || flash[:error]
    flash_message = @flash_message || flash[:message]
    classes = flash_error ? 'flash error' : 'success'
    styles = flash_message.nil? ? '' : 'display:block' 
    
    "<div id=\"statusBar\" class=\"#{classes}\" style=\"#{styles}\">#{h(flash_message)}</div>"
  end
  
  def if_authorized?(action, resource, &block)
     if authorized?(action, resource)
       yield action, resource
     end
   end
   
  def navigation_for_page
   if @projects or @project
     tabnav :projects
   elsif @services or @service
     tabnav :services
   elsif @clients or @client
     tabnav :clients
   end
  end

  def link_to(name, path, attrs={})
    link_attrs = {}
    if path.is_a?(Hash)
      link_attrs[:href] = path[:url] if path.has_key?(:url)
      link_attrs[:'data-remote'] = '1' if path[:'remote']
      link_attrs[:'data-confirm'] = path[:'confirm']  if path.has_key?(:'confirm')
      link_attrs[:'data-method'] = path[:'method'] if path.has_key?(:'method')
    else
      link_attrs[:href] = path
    end


    simple_tag(:a, name, link_attrs.merge(attrs))
  end

  def h(str)
    Rack::Utils.escape_html(str)
  end

  def stylesheet_link_tag(name)
    capture_haml { haml_tag(:link, :rel => 'stylesheet', :href => "/stylesheets/#{name}.css", :type => 'text/css') }
  end

  def attr_to_ts(list)
    list.map {|k,v| v.nil? ? nil : "#{k}=\"#{Rack::Utils.escape_html(v)}\"" }.compact.join(" ")
  end

  def javascript_include_tag(name)
    capture_haml { haml_tag(:script, :src => "/javascripts/#{name}.js") }
  end

  def javascript_tag(code)
    "<script language=text/javascript>#{Rack::Utils.escape_html(code)}</script>"
  end

  def tabnav(name)
    erb :"/shared/_#{name}.html"
  end

  def add_tab(&block)
    t = TabHelper.new
    block.call(t)
    @tab_ctx << t
  end

  def render_tabnav(ident, &block)
    @tab_ctx = []
    block.call
    items = @tab_ctx.join("\n")
    return "<div id=\"#{ident}\"><ul>#{items}</ul></div>"
  end

  def t(key, args={})
    I18n.t(key, args)
  end

  def js_call(object, *attrs)
    attrs = attrs.map {|v| v.to_json }.compact.join(",")
    "#{object}(#{attrs})"
  end

  def js_chain(a, b)
    "#{a}.#{b}"
  end

  def js_prepend(element, content)
    js_call("$('#{element}').prepend", content)
  end

  def js_before(element, content)
    js_call("$('#{element}').before", content)
  end

  def js_replace(element, content)
    js_call("$('#{element}').replaceWith", content)
  end

  def js_element_call(element, name, *attrs)
    js_call("$('#{element}').#{name}", *attrs)
  end

end
