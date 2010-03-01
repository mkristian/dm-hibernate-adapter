require 'java'
module Slf4r
  class LoggerFacade

    protected

    def format(exception)
      (": #{exception.message}:\n\t#{exception.backtrace.join("\n\t") if exception.backtrace }") if exception
    end

    public

    attr_reader :name

    attr_reader :logger
    
    def initialize(name)
      @name = name
      @logger = org.slf4j.LoggerFactory.getLogger(name.to_s.sub(/^::/, '').gsub(/::/, '.'))
    end

    [:debug, :info, :warn, :error].each do |level|
      class_eval <<-CODE
    def #{level}?
      @logger.is_#{level}_enabled
    end

    def #{level}(msg = nil, exception = nil)
      if(@logger.is_#{level}_enabled)
        msg, exception = yield if block_given?        
        if(exception.type == NativeException)
          @logger.#{level}(msg, exception.cause)
        else
          @logger.#{level}("\#{msg}\#{format(exception)}")
        end
      end
    end
CODE
    end
  end
end
