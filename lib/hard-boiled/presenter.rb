module HardBoiled
  require File.dirname(__FILE__)+'/extract_options' unless {}.respond_to?(:extractable_options?)

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

    def self.define object, parent = nil, &block
      new(object, parent).
      instance_eval(&block).
      to_hash
    end

    def initialize subject, parent = nil
      @subject = subject
      @parent_subject = parent
      @hash = {}
    end

    def to_hash
      @hash
    end

    private
    def method_missing id, *args, &block
      options = args.extract_options!
      value = options[:nil] ? nil : (args.shift || (options[:parent] ? parent_subject : subject).__send__(options[:from] || id))
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
          __format_value __apply_filters(value, options), options
        end
      self
    end
    
    def __apply_filters value, options
      if filters = options[:filters]
        filters.inject(value) { |result, filter|
          raise MissingFilterError unless self.respond_to?(filter)
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