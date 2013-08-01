

module OMF
  module ProjectAuthority; end
end


if __FILE__ == $0
  # Run the service
  #
  require 'omf/project_authority/server'

  opts = {
    :app_name => 'project_authority',
    :port => 8002,
    # :am => {
      # :manager => lambda { OMF::SFA::AM::AMManager.new(OMF::SFA::AM::AMScheduler.new) }
    # },
    :ssl => {
      :cert_file => File.expand_path("~/.gcf/am-cert.pem"),
      :key_file => File.expand_path("~/.gcf/am-key.pem"),
      :verify_peer => true
      #:verify_peer => false
    },
    #:log => '/tmp/am_server.log',
    :dm_db => 'sqlite:///tmp/project_authority_test.db',
    :dm_log => '/tmp/project_authority_test-dm.log',
    :rackup => File.dirname(__FILE__) + '/project_authority/config.ru',

  }
  OMF::ProjectAuthority::Server.new.run(opts)

end
