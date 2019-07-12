class Service < Sequel::Model
  many_to_one :user
  one_to_many :entries, :order => 'start_date DESC'

  plugin :association_dependencies
  add_association_dependencies entries: :destroy
  
  attr_accessor :inherit_rate
  ASSIGNABLE_FIELDS = [:name, :tag, :rate, :inherit_rate]

  plugin :whitelist_security
  set_allowed_columns(*ASSIGNABLE_FIELDS)

  plugin :after_initialize

  def after_initialize
    set_inherit
  end
  
  def before_create
    handle_rate
    super
  end

  def set_inherit
    @inherit_rate = true
  end
  
  def handle_rate
    if @inherit_rate
      self.rate = self.user.rate
    else
      self.rate = self.user.rate
    end
  end
  
  def is_default_service?
    self.user.default_service_id == this.id
  end
  
  def total_time
    Entry.sum(:seconds, :conditions => {:service_id => self.id})
  end
  
  def total_expected_time
    Entry.sum(:seconds_limit, :conditions => {:service_id => self.id})
  end
  
  def total_rate
    (Entry.sum(:seconds, :conditions => {:service_id => self.id}) / 60.0 / 60.0) * (rate || 0)
  end
  
  def total_expected_rate
    (Entry.sum(:seconds_limit, :conditions => {:service_id => self.id}) / 60.0 / 60.0) * (rate || 0)
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
      PATHS.services_path
    else
      PATHS.service_path(self)
    end
  end

end
