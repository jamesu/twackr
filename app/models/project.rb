class Project < Sequel::Model
  many_to_one :user
  many_to_one :client
  many_to_one :last_service, :class => 'LastService', :key => 'last_service_id'
  one_to_many :entries, :order => 'start_date DESC'

  plugin :association_dependencies
  add_association_dependencies entries: :destroy
  
  ASSIGNABLE_FIELDS = [:name, :tag, :client_id]

  plugin :whitelist_security
  set_allowed_columns(*ASSIGNABLE_FIELDS)
  
  def build_entry(params)
    e = Entry.new()
    e.set_fields(params, Entry::ASSIGNABLE_FIELDS)
    e[:user_id] = self.user_id
    e[:project_id] = self.id
    e
  end
  
  def is_default_project?
    self.user.default_project_id == this.id
  end
  
  def total_time
    Entry.sum(:seconds, :conditions => {:project_id => self.id})
  end
  
  def total_expected_time
    Entry.sum(:seconds_limit, :conditions => {:project_id => self.id})
  end
  
  def total_rate
    self.entries.find(:all).sum(&:cost)
  end
  
  def total_expected_rate
    self.entries.find(:all).sum(&:expected_cost)
  end

  plugin :validation_helpers
  def validate
    super
    validates_format /[a-zA-Z0-9\-_]*/, :tag, message: 'Tag invalid'
  end

  def update_attributes(params)
    update_fields(params, ASSIGNABLE_FIELDS, :missing => :skip)
    save_changes
    return !modified?
  end

  PATHS = PathDirectory.new

  def form_path
    if new?
      PATHS.projects_path
    else
      PATHS.project_path(self)
    end
  end
end
