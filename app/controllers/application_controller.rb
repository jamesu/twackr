# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  
  layout 'default'
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  before_filter :login_required
  before_filter :set_time_zone

protected

  def error_status(error, message, args={}, continue_ok=true)
    if request.format == :html
      flash[:error] = error
      flash[:message] = t(message, args)
    else
      @flash_error = error
      @flash_message = t(message, args)
    end
    
    return unless (error and continue_ok)
    
    # Construct a reply with a relevant error
    respond_to do |format|
        format.html { redirect_back_or_default('/') }
        format.js { render(:update) do |page| 
                      page.replace_html('statusBar', h(flash[:message]))
                      page.show 'statusBar'
                    end }
        format.xml  { head(error ? :unprocessable_entity : :ok) }
    end
  end
  
  def set_time_zone
    Time.zone = @logged_user.timezone if @logged_user
    @time_now = Time.zone.now
    @date_now = @time_now.to_date
  end
  
  def find_project
    begin
      @project = @logged_user.projects.find(params[:project_id])
    rescue
      respond_to do |f|
        f.html { flash[:error] = t('response.invalid_project')  }
      end
    
      return false
    end
  
    true
  end
  
  def find_project_opt
    begin
      @project = @logged_user.projects.find(params[:project_id])
    rescue
      return true
    end
  
    true
  end
  
end
