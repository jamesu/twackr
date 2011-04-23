class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByCookieToken
  
  has_many :projects,  :dependent => :destroy
  has_many :services,  :dependent => :destroy
  has_many :clients, :dependent => :destroy
  has_many :entries,   :dependent => :destroy, :order => 'start_date DESC'
  
  belongs_to :default_project, :class_name => 'Project', :foreign_key => 'default_project_id'
  belongs_to :default_client, :class_name => 'Client', :foreign_key => 'default_client_id'
  belongs_to :default_service, :class_name => 'Service', :foreign_key => 'default_service_id'
  
  attr_accessible :email, :password, :password_confirmation, :timezone, :rate
  
  before_create :set_timezone
  
  def set_timezone
    self.timezone ||= "UTC"
  end
  
  def self.authenticate(login, pass)
    user = find(:first, :conditions => ["email = ?", login])
    if (!user.nil?) and (user.valid_password(pass))
      now = Time.now.utc
      user.save!
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
      
      break if User.find(:first, :conditions => ["token = ?", token]).nil?
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
  
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of     :email,       :with => Authentication.email_regex, :message => "Invalid email address"
  
  validates_presence_of :password, :if => :password_changed?
  validates_length_of :password, :minimum => 4, :if => :password_changed?
  
  validates_confirmation_of :password, :if => :password_changed?
  
end
