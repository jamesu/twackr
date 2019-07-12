module ServicesController
  module Handlers
  
  def find_service
    begin
      @service = @logged_user.services_dataset.where(:id => params[:id]).first
      raise Exception.new if @service.nil?
    rescue
      respond_to do |f|
        f.html { flash[:error] = t('response.invalid_service')  }
      end

      halt
    end
  end

   end

  def self.registered(app)

  app.helpers ServicesController::Handlers

  app.get '/services' do
    load_session
    @services = @logged_user.services
    
    respond_to do |f|
      f.html { haml :'services/index', :layout => :'layouts/default' }
    end
  end
  
  app.get '/services/new' do
    load_session
    @service = @logged_user.build_service({})
    
    respond_to do |f|
      f.html { haml :'services/new', :layout => :'layouts/default' }
    end
  end
  
  app.post '/services' do
    load_session
    @service = @logged_user.build_service(params[:service])
    
    respond_to do |f|
      if @service.save
        f.html{ redirect(services_path) }
      else
        f.html{ flash.now[:info] = t('response.error'); render :new }
      end
    end
  end
  
  app.get '/services/:id/edit' do
    load_session
    find_service
    haml :'services/edit', :layout => :'layouts/default'
  end
  
  app.put '/services/:id' do
    load_session
    find_service
    respond_to do |f|
      if @service.update_attributes(params[:service])
        f.html{ flash.now[:info] = t('response.saved'); redirect(services_path) }
      else
        f.html{ flash.now[:info] = t('response.error');  haml :'services/edit', :layout => :'layouts/default' }
      end
    end
  end
  
  app.delete '/services/:id' do
    load_session
    find_service
    @service.destroy
    respond_to do |f|
      f.html { redirect services_path }
    end
  end
  
  app.get '/services/:id' do
    load_session
    find_service
    last_id = (params[:last_id] || '0').to_i
    @prev_entry = last_id != 0 ? @logged_user.entries_dataset.where(:id => last_id).first : nil
    @entries = @service.entries_dataset.
      where(last_id > 0 ? Sequel.lit('id < ?', last_id) : {}).
      limit(25).
      order(Sequel.desc(:id)).all
    @last_entry = @entries.length > 0 ? @entries[-1].id : 0
    
    respond_to do |f|
      f.html { haml :'entries/index', :layout => :'layouts/default' }
      f.js {  erb :'entries/index.js' }
    end
  end

  app.get '/services/report' do
    load_session
    @services = @logged_user.services
    @service_times = @services.map {|s| ((s.total_time / 60.0 / 60.0) * 10).round.to_f / 10 }
    @service_rates = @services.map {|s| s.total_rate}
    @service_names = @services.map {|s| s.name}
    
    respond_to do |f|
      f.html {}
    end
  end

end
  
end
