module ClientsController

  module Handlers

  def find_client
    begin
      @client = Client.where(:user_id => @logged_user.id, :id => params[:id]).first
      raise Exception.new if @client.nil?
    rescue
      respond_to do |f|
        f.html { flash[:error] = "Invalid client!"  }
      end

      halt
    end
  end

  end

  def self.registered(app)

  app.helpers ClientsController::Handlers

  app.get '/clients' do
    load_session
    @clients = @logged_user.clients
    
    respond_to do |f|
      f.html { haml :'clients/index', :layout => :'layouts/default' }
    end
  end
  
  app.get '/clients/new' do
    load_session
    @client = @logged_user.build_client
    
    respond_to do |f|
      f.html { haml :'clients/new', :layout => :'layouts/default' }
    end
  end
  
  app.post '/clients' do
    load_session
    @client = @logged_user.build_client(params[:client])
    
    respond_to do |f|
      if @client.save
        f.html{ redirect(clients_path) }
      else
        f.html{ flash.now[:info] = t('response.error'); render :new }
      end
    end
  end
  
  app.get '/clients/:id/edit' do
    load_session
    find_client
    haml :'clients/edit', :layout => :'layouts/default'
  end
  
  app.put '/clients/:id' do
    load_session
    find_client
    respond_to do |f|
      if @client.update_attributes(params[:client])
        f.html{ flash.now[:info] = t('response.saved'); redirect(clients_path) }
      else
        f.html{ flash.now[:info] = t('response.error'); haml :'clients/edit', :layout => :'layouts/default' }
      end
    end
  end
  
  app.delete '/clients/:id' do
    load_session
    find_client
    respond_to do |f|
      if @client.is_default_project?
        f.html { flash[:error] = t('response.client_default'); redirect clients_path }
      else
        @client.destroy
        f.html { redirect clients_path }
      end
    end
  end
  
  app.get '/clients/:id' do
    load_session
    find_client
    @client_projects = @client.projects
    respond_to do |f|
      f.html { haml :'clients/show', :layout => :'layouts/default' }
    end
  end
  
  app.get '/clients/report' do
    load_session
    @clients = @logged_user.clients
    @client_times = @clients.map {|s| ((s.total_time / 60.0 / 60.0) * 10).round.to_f / 10 }
    @client_rates = @clients.map {|s| s.total_rate}
    @client_names = @clients.map {|s| s.name}
    
    respond_to do |f|
      f.html { haml :'clients/:id/report', :layout => :'layouts/default' }
    end
  end

end
end
