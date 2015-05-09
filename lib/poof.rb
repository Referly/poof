require 'active_support/callbacks'
module Poof

  # This module is what should be included into the RSpec config so that poof! is available
  # within specs.
  module Syntax
    def poof!(entity)
      Magic.poof! entity
    end
  end

  class Magic
    # This method acts provides a monotonically increasing integer value
    # As an example if you wanted to make ten companies and didn't want arbitrary names
    # you could start all of them with the same string and prepend the next_safe_key
    # to the domain, ensuring the possibility of uniqueness for the test
    #
    # @return [Integer] the next safe key that can be used to avoid unique key collisions
    def self.next_safe_key
      @next_safe_key ||= 1
      @next_safe_key += 1
    end

    # Get the first item in the container
    #
    # @return [Object] the first item in the container
    def self.get_first
      @container ||= Array.new
      first = @container.first if @container.length > 0
      first ||= nil
    end

    # Get the last item in the container
    #
    # @return [Object] the last item in the container
    def self.get_last
      @container ||= Array.new
      last = @container.last if @container.length > 0
      last ||= nil
    end

    # Get an object matching the description of its factory that is tracked by the container
    # for later reference or teardown
    #
    # @param factory_name [Symbol] the name of the factory you want the container to use
    # @param attributes [Hash] hash where keys are attribute names and values are attribute values
    # @return [Object] the instance generated for the factory you requested
    def self.get(factory_name, attributes = {})
      @container ||= Array.new
      e = FactoryGirl.create(factory_name, attributes)
      @container << e
      e
    end

    # Invoking this method will cause the argument entity to be really_destroy!'d or destroy!'d on next cleanup
    #
    # @param entity [Model] the model entity that should be lazily destroyed
    # @param [Model] the entity that was passed as an argument is returned
    def self.poof!(entity)
      @hit_list ||= Array.new
      @hit_list << entity
      entity
    end

    # This method applies any coercion in the factory's class that would normally occur
    # when getting an instance's attribute (for AR objects this is like calling foo.bar
    # as opposed to foo.read_attribute :bar)
    #
    # @param factory_name [Symbol] the name of the factory that should be used for coercing the attribute
    # @param attribute_name [Symbol] the name of attribute that needs to called on the instance created by the factory
    # @return [Object] the resulting value of calling the instance's method having the name of attribute_name's value
    def self.get_attribute(factory_name, attribute_name)
      e = self.get factory_name
      e.send attribute_name
    end

    # This is the general teardown method, it removes any check_orm's that have been applied
    # to any class for which the container has generated instances, and then it attempts to delete
    # (using hard deletes when possible) all of the instances it created
    def self.cleanup
      @container ||= Array.new
      @container.each do |dependency|
        disable_check_orm(dependency.class)
        teardown_method = :really_destroy! if dependency.respond_to? :really_destroy!
        teardown_method ||= :destroy!
        dependency.send(teardown_method)
      end
      @hit_list ||= Array.new
      @hit_list.each do |trash|
        disable_check_orm(trash.class)
        teardown_method = :really_destroy! if trash.respond_to? :really_destroy!
        teardown_method ||= :destroy!
        trash.send(teardown_method)
      end
    end

    # Selectively targets check_orm_xxx callbacks to be disabled (skipped) in the callback chains
    #
    # @param klasses [Class, Symbol, Array<Class, Symbol>] A Class, Symbol representing a factory_girl factory, or an array Classes or Symbols
    # @param events_to_disable [Symbol, Array] A symbol or array of Symbols that define which kind of callbacks to disable
    def disable_check_orm(klasses, events_to_disable = [:create, :update, :destroy])
      if klasses.is_a? Array
        klasses.map { |klass| disable_check_orm klass, events_to_disable }
      else
        klass = klasses
        if events_to_disable.is_a? Array
          events_to_disable.map { |event| disable_check_orm klass, event }
        else
          event_to_disable = events_to_disable
          # Allow the user to pass a symbol instead of a class and instantiate it using the factory
          # might want to switch to using .new instead, but then you have to figure out how to locate
          # the klasses modularized name from just a symbol representing the class
          if klass.is_a? Symbol
            klass = build(klass).class
          end
          # The name of the actual callback method for destroy is check_orm_delete/check_orm_delete_derived, so need to attach properly
          callback_suffix = :delete if event_to_disable == :destroy
          callback_suffix ||= event_to_disable
          # Get the array of registered check_orm_xxx callbacks from the main authorizer on klass
          registered_check_orm_callbacks = klass.registered_check_orm_callbacks if klass.respond_to? :registered_check_orm_callbacks
          registered_check_orm_callbacks ||= []
          # callbacks_to_skip refers to which callbacks should get passed to the skip_callback method (these are the callbacks that should be effectively disabled)
          callbacks_to_skip = registered_check_orm_callbacks.select { |cb| cb.to_s.include? callback_suffix.to_s }
          callbacks_to_skip ||= []
          callbacks_to_skip.map { |cb| klass.skip_callback(event_to_disable, :before, cb) }
        end
      end
    end

    class << self
      alias_method :start, :cleanup
      alias_method :restart, :cleanup
      alias_method :new_context, :cleanup
      alias_method :end, :cleanup
    end
  end
end