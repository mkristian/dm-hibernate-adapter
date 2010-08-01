module Hibernate
  class Transaction

    attr_reader :session

    def initialize()
      @session = Hibernate.session()
    end

    def close()
      @session.close() if @session
    end

    def begin()
      @session.begin_transaction()
    end

    def commit()
      @session.transaction().commit()
    end

    def rollback()
      @session.transaction().rollback() if @session
    end

  end
end
