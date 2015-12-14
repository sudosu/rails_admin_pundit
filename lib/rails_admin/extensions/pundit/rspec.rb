require "active_support/core_ext/array/conversions"

module RailsAdmin
  module Extensions
    module Pundit
      module RSpec
        # module Matchers
        #   extend ::RSpec::Matchers::DSL
        #
        #
        # end

        module DSL
          def rails_admin_permissions(*list, &block)
            describe(list.to_sentence, :caller => caller) do
              instance_eval(&block)

              matcher :permit do |user, record, action|
                match_proc = lambda do |policy|
                  policy.new(user, record).rails_admin?(action)
                end

                match_when_negated_proc = lambda do |policy|
                  !policy.new(user, record).rails_admin?(action)
                end

                failure_message_proc = lambda do |policy|
                  "Expected #{policy} to grant #{action} on #{record} to user #{user} but it didn't"
                end

                failure_message_when_negated_proc = lambda do |policy|
                  "Expected #{policy} not to grant #{action} on #{record} to user #{user} but it did"
                end

                if respond_to?(:match_when_negated)
                  match(&match_proc)
                  match_when_negated(&match_when_negated_proc)
                  failure_message(&failure_message_proc)
                  failure_message_when_negated(&failure_message_when_negated_proc)
                else
                  match_for_should(&match_proc)
                  match_for_should_not(&match_when_negated_proc)
                  failure_message_for_should(&failure_message_proc)
                  failure_message_for_should_not(&failure_message_when_negated_proc)
                end

                def permissions
                  current_example = ::RSpec.respond_to?(:current_example) ? ::RSpec.current_example : example
                  current_example.metadata[:permissions]
                end
              end

            end
          end
        end

        module PolicyExampleGroup

          def self.included(base)
            base.metadata[:type] = :rails_admin_policy
            base.extend RailsAdmin::Extensions::Pundit::RSpec::DSL
            super
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  if RSpec::Core::Version::STRING.split(".").first.to_i >= 3
    config.include(RailsAdmin::Extensions::Pundit::RSpec::PolicyExampleGroup, {
                                                                                :type => :rails_admin_policy,
                                                                                :file_path => /spec\/policies/,
                                                                            })
  else
    config.include(RailsAdmin::Extensions::Pundit::RSpec::PolicyExampleGroup, {
                                                                                :type => :rails_admin_policy,
                                                                                :example_group => {:file_path => /spec\/policies/}
                                                                            })
  end
end