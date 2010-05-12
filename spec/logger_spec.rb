require 'java_logger'

org.apache.log4j.PropertyConfigurator.configure(File.dirname(__FILE__) + '/log4j.properties')

describe 'logger' do

  it 'should' do
    @logger = Slf4r::LoggerFacade.new(Slf4r::LoggerFacade)
    @logger.debug("test")
    p @logger
  end

end
