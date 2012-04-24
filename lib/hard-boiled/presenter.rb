module HardBoiled
  # Boilerplate
  require File.dirname(__FILE__)+'/extract_options' unless {}.respond_to?(:extractable_options?)
  require File.dirname(__FILE__)+'/blank' unless nil.respond_to?(:blank?)

  # This class pretty much resembles what Thoughtbot did in
  # [FactoryGirl's DefinitionProxy](https://github.com/thoughtbot/factory_girl/blob/master/lib/factory_girl/definition_proxy.rb)
  # although it just reduces a `class` to a simple `Hash`
  class Presenter
    class MissingFilterError < StandardError; end
    UNPROXIED_METHODS = %w(__send__ __id__ nil? respond_to? class send object_id extend instance_eval initialize block_given? raise)

    (instance_methods + private_instance_methods).each do |m|
      undef_method m unless UNPROXIED_METHODS.include? m
    end

    attr_reader :subject, :parent_subject

    def self.define *args, &block
      # if I could only remove the duplicate `obj`
      obj = new(*args)
      obj.instance_eval(&block)
      obj.to_hash
    end

    def initialize *args
      @options = args.extract_options!
      @subject, @parent_subject = args
      @hash = {}
    end


    # Decide whether the given trait is being needed
    #
    # @param [Symbol] name the identifier for a trait, like :profile
    # @param [Hash{:only => Array, :except => Array}]
    # @return [true, false] dependening on in- or exclusion of this trait
    def with_trait name, &block
      if (@options[:except].blank? || !@options[:except].include?(name)) &&
        (@options[:only].blank? || @options[:only].include?(name))
        self.instance_eval(&block)
      end
    end

    def to_hash
      @hash
    end

    private
    def method_missing id, *args, &block
      options = args.extract_options!
      params = options[:params]
      value =
        if options[:nil]
          nil
        else
          if static = args.shift
            static
          else
            object = options[:parent] ? parent_subject : subject
            method_name = options[:from] || id
            if params
              object.__send__ method_name, *params
            else
              object.__send__ method_name
            end
          end
        end
      @hash[id] =
        if block_given?
          if value.kind_of? Array
            value.map do |v|
              self.class.define(v, self.subject, &block)
            end
          else
            self.class.define(value, self.subject, &block)
          end
        else
          __set_defaults __format_value(__apply_filters(value, options), options), options
        end
      self
    end

    def __set_defaults value, options
      if value.nil? and default = options[:default]
        default
      else
        value
      end
    end

    def __apply_filters value, options
      if filters = options[:filters]
        filters.inject(value) { |result, filter|
          raise MissingFilterError, filter.to_s unless self.respond_to?(filter)
          self.__send__(filter, result)
        }
      else
        value
      end
    end

    def __format_value value, options
      (format = options[:format]) ? format % value : value
    end
  end
end