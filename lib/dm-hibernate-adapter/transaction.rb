# -*- coding: utf-8 -*-
# Copyright 2011 Douglas Ferreira, Kristian Meier, Piotr Gęga

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Hibernate

  class Transaction

    attr_reader :session

    def initialize
      @session = Hibernate.session
    end

    def close
      @session.close if @session
    end

    def begin
      @session.begin_transaction if @session
    end

    def commit
      @session.transaction.commit if @session
    end

    def rollback
      @session.transaction.rollback if @session
    end

  end

end
