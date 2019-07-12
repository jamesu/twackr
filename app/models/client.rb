class Client < Sequel::Model
  many_to_one :user
  one_to_many :projects, :dependent => :destroy
  one_to_many :entries, :through => :projects, :order => 'start_date DESC' do |b|
    b.inner_join(:projects, :id, :client_id)
  end
  
  ASSIGNABLE_FIELDS = [:name]

  plugin :whitelist_security
  set_allowed_columns(*ASSIGNABLE_FIELDS)
  
  def is_default_client?
    self.user.default_client_id == this.id
  end
  
  def total_time(project=nil)
    projs = project.nil? ? self.project_ids : project.id
    Entry.sum(:seconds, :conditions => {:project_id => projs})
  end
  
  def total_expected_time(project=nil)
    projs = project.nil? ? self.project_ids : project.id
    Entry.sum(:seconds_limit, :conditions => {:project_id => projs})
  end
  
  def total_rate(project=nil)
    projs = project.nil? ? self.project_ids : project.id
    self.entries.find(:all, :conditions => {:project_id => projs}).sum(&:cost)
  end
  
  def total_expected_rate(project=nil)
    self.entries.find(:all, :conditions => {:project_id => projs}).sum(&:expected_cost)
  end

  def update_attributes(params)
    update_fields(params, ASSIGNABLE_FIELDS, :missing => :skip)
    save_changes
    return !modified?
  end

  PATHS = PathDirectory.new

  def form_path
    if new?
      PATHS.clients_path
    else
      PATHS.client_path(self)
    end
  end
  
end
