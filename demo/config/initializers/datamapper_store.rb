# init a session store which uses a memory cache and a persistent store
# cleanup can be a problem. jruby uses soft-references for the cache so
# memory cleanup with jruby is not a problem.
require 'datamapper4rails/datamapper_store'
ActionController::Base.session_store = :datamapper_store
ActionController::Base.session = {
  :cache       => true,
}
