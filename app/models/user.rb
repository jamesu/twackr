class User < Sequel::Model
  one_to_many :projects
  one_to_many :services
  one_to_many :clients
  one_to_many :entries, :order => 'start_date DESC'

  plugin :association_dependencies
  add_association_dependencies projects: :destroy, services: :destroy, clients: :destroy, entries: :destroy
  
  many_to_one :default_project, :class => 'Project', :key => 'default_project_id'
  many_to_one :default_client, :class => 'Client', :key => 'default_client_id'
  many_to_one :default_service, :class => 'Service', :key => 'default_service_id'
  
  ASSIGNABLE_FIELDS = [:email, :password, :password_confirmation, :timezone, :rate]

  plugin :whitelist_security
  set_allowed_columns(*ASSIGNABLE_FIELDS)

  attr_accessor :password, :password_confirmation

  def build_entry(params)
    e = Entry.new()
    e.set_fields(params, Entry::ASSIGNABLE_FIELDS)
    e[:user_id] = self.user_id
    e[:project_id] = self.default_project_id
    e
  end

  def build_project(params)
    e = Project.new()
    e.set_fields(params, Project::ASSIGNABLE_FIELDS)
    e[:user_id] = self.id
    e
  end

  def build_client(params)
    e = Client.new()
    e.set_fields(params, Client::ASSIGNABLE_FIELDS)
    e[:user_id] = self.id
    e
  end

  def build_service(params)
    e = Service.new()
    e.set_fields(params, Service::ASSIGNABLE_FIELDS)
    e[:user_id] = self.id
    e
  end

  def project_ids
    projects_dataset.select(:id).naked.all.map(&:values).flatten
  end

  def before_create
    set_timezone
  end
  
  def set_timezone
    self.timezone ||= "UTC"
  end
  
  def self.authenticate(login, pass)
    user = where(:email => login).first
    if (!user.nil?) and (user.valid_password(pass))
      now = Time.now.utc
      user.save_changes(:raise_on_save_failure => true)
      return user
    else
      return nil
    end
  end

  def password=(value)
    salt = nil
    token = nil
    
    return if value.empty?
    
    if value.nil?
      self.salt = nil
      self.token = nil
      return
    end
    
    # Calculate a unique token with salt
    loop do
      # Grab a few random things...
      tnow = Time.now()
      sec = tnow.tv_usec
      usec = tnow.tv_usec % 0x100000
      rval = rand()
      roffs = rand(25)
      
      # Now we can calculate salt and token
      salt = Digest::SHA1.hexdigest(sprintf("%s%08x%05x%.8f", rand(32767), sec, usec, rval))[roffs..roffs+12]
      token = Digest::SHA1.hexdigest(salt + value)
      
      break if User.where(:token => token).first.nil?
    end
    
    self.salt = salt
    self.token = token
    
    @cached_password = value.clone
  end
  
  def password
    @cached_password
  end
  
  def password_changed?
    !@cached_password.nil?
  end
  
  def valid_password(pass)
    return self.token == Digest::SHA1.hexdigest(self.salt + pass)
  end

  # AUTH

  def remember_token?
    tok = remember_token||''
    (!tok.strip.empty?) && 
      remember_token_expires_at && (Time.now.utc < remember_token_expires_at.utc)
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for(86400*14)
  end

  def remember_me_for(time)
    remember_me_until Time.now.utc + time
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = self.class.make_token
    save_changes(:raise_on_save_failure => true)
  end

  # refresh token (keeping same expires_at) if it exists
  def refresh_token
    if remember_token?
      self.remember_token = self.class.make_token 
      save_changes(:raise_on_save_failure => true)    
    end
  end

  # 
  # Deletes the server-side record of the authentication token.  The
  # client-side (browser cookie) and server-side (this remember_token) must
  # always be deleted together.
  #
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save_changes(:raise_on_save_failure => true)
  end


  def self.secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

  def self.make_token
    secure_digest(Time.now, (1..10).map{ rand.to_s })
  end

  #


  plugin :validation_helpers
  def validate
    super
    validates_presence :email
    validates_unique :email
    #validates_format email_regex, message: "Invalid email address"

    if password_changed?
      validates_presence :password
      validates_min_length 4, :password
      errors.add(:password, 'needs to be confirmed') if self.password != self.password_confirmation
    end
  end

  def update_attributes(params)
    set_fields(params, ASSIGNABLE_FIELDS, :missing => :skip)
    save_changes() rescue nil
    return !modified?
  end

  PATHS = PathDirectory.new

  def form_path
    if new?
      PATHS.users_path
    else
      PATHS.user_path(self)
    end
  end

end
