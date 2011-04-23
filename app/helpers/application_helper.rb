# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def status_bar
    flash_error = @flash_error || flash[:error]
    flash_message = @flash_message || flash[:message]
    classes = flash_error ? 'flash error' : 'success'
    styles = flash_message.nil? ? '' : 'display:block' 
    
    "<div id=\"statusBar\" class=\"#{classes}\" style=\"#{styles}\">#{h(flash_message)}</div>".html_safe
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
end
