require 'active_record'

module CustomHasSecurePassword

  extend ActiveSupport::Concern

  module ClassMethods

    def custom_has_secure_password
      attr_reader :password

      include SecurePasswordInstanceMethods

      if respond_to?(:attributes_protected_by_default)
        def self.attributes_protected_by_default
          super + ['password_digest']
        end
      end
    end

  end

  module SecurePasswordInstanceMethods
    # Returns self if the password is correct, otherwise false.
    def authenticate(unencrypted_password)
      if BCrypt::Password.new(password_digest) == unencrypted_password
        self
      else
        false
      end
    end

    # Encrypts the password into the password_digest attribute.
    def password=(unencrypted_password)
      @password = unencrypted_password
      unless unencrypted_password.blank?
        self.password_digest = BCrypt::Password.create(unencrypted_password)
      end
    end
  end

end

ActiveRecord::Base.send(:include, CustomHasSecurePassword)
