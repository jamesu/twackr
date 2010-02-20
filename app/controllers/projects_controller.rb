class ProjectsController < ApplicationController
  before_filter :find_project, :except => [:index, :entries, :new, :create]
  
  def index
    @projects = @logged_user.projects
    respond_to do |f|
      f.html {}
    end
  end
  
  def entries
    @projects = @logged_user.projects
    @entries = @logged_user.entries.find(:all, :conditions => {:project_id => @logged_user.project_ids}, :order => 'start_date DESC')
    respond_to do |f|
      f.html {render 'entries/index'}
    end
  end
  
  def new
    @project = @logged_user.projects.build
  end
  
  def create
    @project = @logged_user.projects.build(params[:project])
    
    respond_to do |f|
      if @project.save
        f.html{ flash.now[:info] = "Created!"; redirect_to(projects_path) }
      else
        f.html{ flash.now[:info] = "Error!"; render :new }
      end
    end
  end
  
  def edit
  end
  
  def update
    respond_to do |f|
      if @project.update_attributes(params[:project])
        f.html{ flash.now[:info] = "Saved!"; redirect_to(projects_path) }
      else
        f.html{ flash.now[:info] = "Error!"; render :edit }
      end
    end
  end
  
  def destroy
    respond_to do |f|
      if @project.is_default_project?
        f.html { flash[:error] = "Project is default"; redirect_to projects_path }
      else
        @project.destroy
        f.html { redirect_to projects_path }
      end
    end
  end
  
  def show
    @entries = @project.entries
    respond_to do |f|
      f.html {render 'entries/index'}
    end
  end
  
  def report
    @projects = @logged_user.projects
    @project_times = @projects.map {|s| ((s.total_time / 60.0 / 60.0) * 10).round.to_f / 10 }
    @project_rates = @projects.map {|s| s.total_rate}
    @project_names = @projects.map {|s| s.name}
    
    respond_to do |f|
      f.html {}
    end
  end

private

  def find_project
    begin
      @project = @logged_user.projects.find(params[:id])
    rescue
      respond_to do |f|
        f.html { flash[:error] = "Invalid project!"  }
      end

      return false
    end

    true
  end

end
