require 'active_support/callbacks'
module Poof
  # This module is what should be included into the RSpec config so that poof! is available
  # within specs.
  module Syntax
    def poof!(entity)
      Magic.poof! entity
    end

    def cleanup
      Magic.cleanup
    end

    alias_method :start, :cleanup
    alias_method :restart, :cleanup
    alias_method :new_context, :cleanup
    alias_method :end, :cleanup
  end
  extend Syntax

  def Poof.get(factory_name, attributes = {})
    Magic.get factory_name, attributes
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

    def self.configure
      yield(configuration) if block_given?
    end

    # This is the general teardown method, it removes any check_orm's that have been applied
    # to any class for which the container has generated instances, and then it attempts to delete
    # (using hard deletes when possible) all of the instances it created
    def self.cleanup
      @container ||= Array.new
      @container.each do |dependency|
        configuration.callback_buster.call(dependency.class)
        teardown_method = :really_destroy! if dependency.respond_to? :really_destroy!
        teardown_method ||= :destroy!
        dependency.send(teardown_method)
      end
      @hit_list ||= Array.new
      @hit_list.each do |trash|
        configuration.callback_buster.call(trash.class)
        teardown_method = :really_destroy! if trash.respond_to? :really_destroy!
        teardown_method ||= :destroy!
        trash.send(teardown_method)
      end
    end

  private
    def self.configuration
      if @configuration.nil?
        @configuration = OpenStruct.new
        @configuration.callback_buster = Proc.new { |klass| }
      end
      @configuration
    end
  end
end