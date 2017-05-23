class Account < Sequel::Model
  one_to_many :surveys
  one_to_many :created_themes
  one_to_many :categories
  many_to_many :assigned_themes, :join_table => :account_theme
  plugin :validation_helpers

  attr_accessor :password, :password_confirmation
  
  def draft_surveys
    surveys.select { |s| s.status == 'draft' }
  end

  def active_surveys
    surveys.select { |s| s.status == 'active' }
  end

  def finished_surveys
    surveys.select { |s| s.status == 'finished' }
  end

  def find_survey_by_theme(theme_id)
    if self.surveys.count > 0
      survey_with_theme =  self.surveys.select{|item| item.theme_id == theme_id}
      return survey_with_theme
    end
    return []
  end
  
  def validate
    validates_presence     :email
    validates_presence     :role
    validates_presence     :password if password_required
    validates_presence     :password_confirmation if password_required
    validates_length_range 4..40, :password unless password.blank?
    errors.add(:password_confirmation, 'must confirm password') if !password.blank? && password != password_confirmation
    validates_length_range 3..100, :email unless email.blank?
    validates_unique       :email unless email.blank?
    validates_format       /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :email unless email.blank?
    validates_format       /[A-Za-z]/, :role unless role.blank?
  end

  # Callbacks
  def before_save
    encrypt_password
	create_remember_token
  end

  ##
  # This method is for authentication purpose.
  #
  def self.authenticate(email, password)
    account = filter(Sequel.function(:lower, :email) => Sequel.function(:lower, email)).first
    account && account.has_password?(password) ? account : nil
  end

  ##
  # Replace ActiveRecord method.
  #
  def self.find_by_id(id)
    self[id] rescue nil
  end

  def has_password?(password)
    ::BCrypt::Password.new(self.crypted_password) == password
  end

  private

  def encrypt_password
    self.crypted_password = ::BCrypt::Password.create(password) if password.present?
  end

  def password_required
    self.crypted_password.blank? || password.present?
  end
  
  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64 # Generate token
  end
end
