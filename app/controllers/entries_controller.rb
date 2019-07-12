module EntriesController

  module Handlers

  def make_time_list(start_date, end_date, &block)
    # includes start, up to and including end
    cur_date = start_date
    list = []
    while (cur_date <= end_date)
      list << block.call(cur_date)
      cur_date += 1
    end
    list
  end
  
  def find_entry
    begin
      @entry = (@project || @logged_user).entries_dataset.where(:id => params[:id]).first
      raise Exception.new if @entry.nil?
    rescue
      respond_to do |f|
        f.html { flash[:error] = t('response.invalid_entry')  }
      end

      halt
    end
  end

  end


  def self.registered(app)

  app.helpers EntriesController::Handlers

  app.get '/entries' do
    load_session
    find_project_opt
    @projects = @logged_user.projects

    obj = (@project || @logged_user)

    last_id = (params[:last_id] || '0').to_i
    @prev_entry = last_id != 0 ? @logged_user.entries_dataset.where(:id =>last_id).first : nil
    @entries = obj.entries_dataset.
      where(last_id > 0 ? Sequel.lit('id < ?', last_id) : {}).
      limit(25).
      order(Sequel.desc(:id)).all
    @last_entry = @entries.length > 0 ? @entries[-1].id : 0

    respond_to do |f|
      f.html { haml :'entries/index', :layout => :'layouts/default' }
      f.js { erb :'entries/index.js' }
    end
  end
  
  app.get '/entries/new' do
    load_session
    find_project
    @entry = @project.entries.new
  end
  
  app.post '/entries' do
    load_session
    find_project_opt

    dat = params[:entry].merge(:user_id => @logged_user.id)
    @entry = (@project || @logged_user.default_project).build_entry(dat)

    respond_to do |f|
      if @entry.save
        f.html{ redirect(entries_path) }
        f.js { erb :'entries/create.js' }
      else
        f.html{ flash.now[:info] = t('response.error'); haml :'entries/new', :layout => :'layouts/default' }
        f.js { erb :'entries/edit.js' }
      end
    end
  end
  
  app.get '/entries/:id/edit' do
    load_session
    find_project_opt
    find_entry

    respond_to do |f|
      f.js { erb :'entries/edit.js' }
    end
  end
  
  app.put '/entries/:id' do
    load_session
    find_project_opt
    find_entry

    respond_to do |f|
      if @entry.update_attributes(params[:entry])
        f.html{ flash.now[:info] = t('response.saved'); redirect(entries_path) }
        f.js { erb :'entries/update.js' }
      else
        f.html{ flash.now[:info] = t('response.error'); haml :'entries/edit', :layout => :'layouts/default' }
        f.js { erb :'entries/edit.js' }
      end
    end
  end
  
  app.put '/entries/:id/restart' do
    load_session
    find_entry
    @cloned_entry = @project.entries.build()
    @cloned_entry.clone_from(@entry)
    @entry = @cloned_entry
    
    respond_to do |f|
      if @entry.save
        f.html{ flash.now[:info] = t('response.entry_cloned'); redirect(entries_path) }
        f.js { erb :'entries/create.js' }
      else
        f.html{ flash.now[:info] = t('response.error'); haml :'entries/edit', :layout => :'layouts/default'}
      end
    end
  end
  
  app.put '/entries/:id/terminate' do
    load_session
    find_entry
    @entry.quick_update = true
    @entry.terminate
    
    respond_to do |f|
      if @entry.save
        f.html{ flash.now[:info] = t('response.entry_terminated'); redirect(entries_path) }
        f.js { erb :'entries/update.js' }
      else
        f.html{ flash.now[:info] = t('response.error'); haml :'entries/edit', :layout => :'layouts/default' }
      end
    end
  end
  
  app.delete '/entries/:id' do
    load_session
    find_entry
    @entry_id = @entry.id
    @entry.destroy
    respond_to do |f|
      f.html { redirect(entries_path) }
      f.js { erb :'entries/destroy.js' }
    end
  end
  
  app.get '/entries/:id' do
    load_session
    find_entry
    respond_to do |f|
      f.js { erb :'entries/update.js' }
    end
  end
  
  app.get '/entries/report' do
    load_session
    find_project_opt
    now = params[:date] ? Date.parse(params[:date]) : Time.now.to_date
    now_t = now.to_time
    report_period = params[:period]
    report_year = now.year
    
    days_past_week  = Proc.new {|entry| d=(now - entry.date); d < 0 || d > 6}
    days_past_period  = Proc.new {|entry| d=(now - entry.date); d < 0 || d > 5*7}
    days_this_year  = Proc.new {|entry| now.year != entry.year}
    
    case report_period
    when 'week'
      day_list = make_time_list(now - (5*7) + 1, now) {|d| d.cweek}.uniq
      daymap = {}
      day_list.each{|d| daymap[d] = d }
      @grouped_entries = @logged_user.entries.reject(&days_past_period).group_by do |entry|
        entry.date.cweek
      end
    else
      day_list = make_time_list(now - 1.week + 1, now) {|d| d.cwday}.uniq
      daymap = ["", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun"]
      @grouped_entries = @logged_user.entries.reject(&days_past_week).group_by do |entry|
        #puts "GROUP #{entry.date} #{entry.date.cwday} -> #{entry.hours}"
        entry.date.cwday
      end
    end
    
    @summed_rates = day_list.map do |key|
      if @grouped_entries.has_key?(key)
        [key, @grouped_entries[key].map{|e|e.cost}.sum]
      else
        [key, 0]
      end
    end
    
    @summed_expected_rates = day_list.map do |key|
      if @grouped_entries.has_key?(key)
        [key, @grouped_entries[key].map{|e|e.expected_cost}.sum]  
      else
        [key, 0]
      end
    end
    
    @summed_times = day_list.map do |key|
      if @grouped_entries.has_key?(key)
        [key, @grouped_entries[key].map{|e|e.hours}.sum]  
      else
        [key, 0]
      end
    end
    
    @summed_expected_times = day_list.map do |key|
      if @grouped_entries.has_key?(key)
        [key, @grouped_entries[key].map{|e|e.hours_limit}.sum]  
      else
        [key, 0]
      end
    end
    
    @sum_range_list = day_list.map {|d|daymap[d]}
    
    respond_to do |f|
      f.html { haml :'entries/report', :layout => :'layouts/default' }
    end
  end

end
end
