class UsersController < ApplicationController
  skip_before_filter :login_required, :only => [:new, :create]
  before_filter :find_user, :except => [:index, :new, :create, :settings]
  before_filter :check_edit?, :only => [:edit, :update, :destroy, :show]
  
  layout :user_layout
  
  def index
    respond_to do |f|
      if @logged_user.admin
        f.html{}
      else
        f.html{redirect_to user_path(@logged_user)}
      end
    end
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    
    respond_to do |f|
      if @user.save
        default_client = @user.clients.build(:name => 'Self')
        default_client.save
        default_project = @user.projects.build(:name => 'Default', :tag => 'self')
        default_project.client = default_client
        default_project.save
        default_service = @user.services.build(:name => 'Default', :tag => 'self')
        default_service.save
        
        @user.default_client = default_client
        @user.default_project = default_project
        @user.default_service = default_service
        
        @user.save
        
        self.current_user = @user
        f.html{ flash.now[:info] = "Saved!"; redirect_to(projects_path) }
      else  
        f.html{ flash.now[:error] = "Error saving!"; render :new }
      end
    end
  end
  
  def edit
  end
  
  def settings
    @user = @logged_user
    render :action => :edit
  end
  
  def update
    respond_to do |f|
      if @user.update_attributes(params[:user])
        f.html{ flash.now[:info] = "Saved!"; redirect_to(root_path) }
      else
        f.html{ flash.now[:info] = "Error!"; render :edit }
      end
    end
  end
  
  def destroy
    destroyed = false
    if @logged_user == @user or @logged_user.admin
      self.current_user = nil if @logged_user == @user
      @user.destroy
      destroyed = true
    end
    
    respond_to do |f|
      f.html { redirect_to root_path }
    end
  end
  
  def show
  end

private

  def find_user
    begin
      @user = User.find(params[:id])
    rescue
      respond_to do |f|
        f.html { flash[:error] = "Invalid user!"  }
      end
      
      return false
    end
    
    true
  end
  
  def check_edit?
    unless @logged_user.admin or @logged_user == @user
      respond_to do |f|
        f.html{ flash[:error] = "Invalid user!"; redirect_to '/' }
      end
      return false
    end
    
    true
  end
  
  def user_layout
    ['new', 'create'].include?(action_name) ? 'dialog' : 'default'
  end
  
end
