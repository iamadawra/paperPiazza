require 'active_record'

module HasRoles

  extend ActiveSupport::Concern

  module ClassMethods

    def has_roles(model, through_association = nil)
      table_name = model.name.underscore.pluralize
      through_association ||= table_name
      add_role = lambda { |role|
        self.class_eval <<-eos
          has_many :#{role.downcase}s, 
                    :source => :user,
                    :through => :#{through_association}, 
                    :conditions => ['#{table_name}.role = ?',
                                    #{model.name}.#{role}_role]
          def has_#{role}?(user)
            membership = self.memberships.for_user(user)
            return false unless membership
            return membership.role == #{model.name}.#{role}_role
          end
        eos
      }
      self.class.send(:define_method, :add_role, add_role)
    end
  end

end

ActiveRecord::Base.send(:include, HasRoles)
