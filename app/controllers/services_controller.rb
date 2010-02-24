class ServicesController < ApplicationController
  before_filter :find_service, :except => [:index, :new, :create, :reports]

  def index
    @services = @logged_user.services
    
    respond_to do |f|
      f.html {}
    end
  end
  
  def new
    @service = @logged_user.services.build()
  end
  
  def create
    @service = @logged_user.services.build(params[:service])
    
    respond_to do |f|
      if @service.save
        f.html{ redirect_to(services_path) }
      else
        f.html{ flash.now[:info] = t('response.error'); render :new }
      end
    end
  end
  
  def edit
  end
  
  def update
    respond_to do |f|
      if @service.update_attributes(params[:service])
        f.html{ flash.now[:info] = t('response.saved'); redirect_to(services_path) }
      else
        f.html{ flash.now[:info] = t('response.error'); render :edit }
      end
    end
  end
  
  def destroy
    @service.destroy
    respond_to do |f|
      f.html { redirect_to services_path }
    end
  end
  
  def show
    last_id = (params[:last_id] || '0').to_i
    @entries = @service.entries.find(:all, 
      :conditions => last_id > 0 ? ['id < ?', last_id] : {}, 
      :limit => 25, 
      :order => 'start_date DESC')
    @last_entry = @entries.length > 0 ? @entries[-1].id : 0
    
    respond_to do |f|
      f.html {render 'entries/index'}
      f.js {render 'entries/index'}
    end
  end

  def report
    @services = @logged_user.services
    @service_times = @services.map {|s| ((s.total_time / 60.0 / 60.0) * 10).round.to_f / 10 }
    @service_rates = @services.map {|s| s.total_rate}
    @service_names = @services.map {|s| s.name}
    
    respond_to do |f|
      f.html {}
    end
  end
  
private

  def find_service
    begin
      @service = @logged_user.services.find(params[:id])
    rescue
      respond_to do |f|
        f.html { flash[:error] = t('response.invalid_service')  }
      end

      return false
    end

    true
  end
  
end
