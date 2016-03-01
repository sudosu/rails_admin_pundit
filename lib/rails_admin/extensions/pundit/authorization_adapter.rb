module RailsAdmin
  module Extensions
    module Pundit
      # This adapter is for the Pundit[https://github.com/elabs/pundit] authorization library.
      # You can create another adapter for different authorization behavior, just be certain it
      # responds to each of the public methods here.
      class AuthorizationAdapter
        # See the +authorize_with+ config method for where the initialization happens.
        def initialize(controller)
          @controller = controller
          @controller.class.send(:alias_method, :pundit_user, :_current_user)
        end

        # This method is called to find authorization policy
        def policy(record)
          begin
            @controller.policy(record)
          rescue ::Pundit::NotDefinedError
            ::ApplicationPolicy.new(@controller.send(:_current_user), record)
          end
        end
        private :policy

        # This method is called in every controller action and should raise an exception
        # when the authorization fails. The first argument is the name of the controller
        # action as a symbol (:create, :bulk_delete, etc.). The second argument is the
        # AbstractModel instance that applies. The third argument is the actual model
        # instance if it is available.
        def authorize(action, abstract_model = nil, model_object = nil)
          @controller.instance_variable_set(:@_policy_authorized, true)
          record = model_object || abstract_model && abstract_model.model
          unless policy(record).rails_admin?(action)
            raise ::Pundit::NotAuthorizedError, "not allowed to #{action} this #{record}"
          end
        end

        # This method is called primarily from the view to determine whether the given user
        # has access to perform the action on a given model. It should return true when authorized.
        # This takes the same arguments as +authorize+. The difference is that this will
        # return a boolean whereas +authorize+ will raise an exception when not authorized.
        def authorized?(action, abstract_model = nil, model_object = nil)
          record = model_object || abstract_model && abstract_model.model
          policy(record).rails_admin?(action)
        end

        # This is called when needing to scope a database query. It is called within the list
        # and bulk_delete/destroy actions and should return a scope which limits the records
        # to those which the user can perform the given action on.
        def query(action, abstract_model)
          begin
            @controller.policy_scope(abstract_model.model)
          rescue ::Pundit::NotDefinedError
            abstract_model.model.all
          end
        end

        # This is called in the new/create actions to determine the initial attributes for new
        # records. It should return a hash of attributes which match what the user
        # is authorized to create.
        def attributes_for(action, abstract_model)
          record = abstract_model && abstract_model.model
          policy(record).try(:attributes_for, action) || {}
        end
      end
    end
  end
end
