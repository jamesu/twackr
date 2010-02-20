module EntriesHelper
  def new_entry_form(project, client, service)
    render :partial => 'entries/new', :locals => {
      :project => project,
      :service => service,
      :entry => Entry.new }
  end
  
  def entry_tag(type, value)
    "<div class=\"#{type}\">#{value.escape_html}</div>"
  end
  
  def friendly_time(seconds)
    minutes = seconds / 60.0 # 22
    hours = minutes / 60.0   # 0.3
    hours = hours.floor
    minutes = (minutes - (hours * 60.0)).floor
    
    #return "#{hours}H#{minutes}M#{seconds}S"
      
    if hours < 1.0
      if minutes < 1
        return "#{seconds}S"
      else
        return "#{minutes}M"
      end
    else
      return "#{hours}H#{minutes}M"
    end
  end
  
  def entry_project_tag(tag)
    "<span class=\"project\">\@#{tag}</span>"
  end
  
  def entry_service_tag(tag)
    "<span class=\"service\">\##{tag}</span>"
  end
  
  def entry_bar_report(id, values, labels)
    js_labels = labels.map{|l| "'#{l}'"}
    "<div id=\"#{id}\" style=\"width:300px; height: 200px;\"></div>" +
    javascript_tag("Report.makeBar('#{id}', [#{values.join(',')}], [#{js_labels.join(',')}])")
  end
end
