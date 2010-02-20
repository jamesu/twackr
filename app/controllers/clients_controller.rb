class ClientsController < ApplicationController
  before_filter :find_client, :except => [:index, :new, :create]
  
  def index
    @clients = @logged_user.clients
    
    respond_to do |f|
      f.html {}
    end
  end
  
  def new
    @client = @logged_user.clients.build()
  end
  
  def create
    @client = @logged_user.clients.build(params[:client])
    
    respond_to do |f|
      if @client.save
        f.html{ flash.now[:info] = "Created!"; redirect_to(clients_path) }
      else
        f.html{ flash.now[:info] = "Error!"; render :new }
      end
    end
  end
  
  def edit
  end
  
  def update
    respond_to do |f|
      if @client.update_attributes(params[:client])
        f.html{ flash.now[:info] = "Saved!"; redirect_to(clients_path) }
      else
        f.html{ flash.now[:info] = "Error!"; render :edit }
      end
    end
  end
  
  def destroy
    respond_to do |f|
      if @client.is_default_project?
        f.html { flash[:error] = "Client is default"; redirect_to clients_path }
      else
        @client.destroy
        f.html { redirect_to clients_path }
      end
    end
  end
  
  def show
    @client_projects = @client.projects
    respond_to do |f|
      f.html {}
    end
  end
  
  def report
    @clients = @logged_user.clients
    @client_times = @clients.map {|s| ((s.total_time / 60.0 / 60.0) * 10).round.to_f / 10 }
    @client_rates = @clients.map {|s| s.total_rate}
    @client_names = @clients.map {|s| s.name}
    
    respond_to do |f|
      f.html {}
    end
  end

protected

  def find_client
    begin
      @client = @logged_user.clients.find(params[:id])
    rescue
      respond_to do |f|
        f.html { flash[:error] = "Invalid client!"  }
      end
    
      return false
    end
  
    true
  end

end
