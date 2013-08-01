require 'rubygems'

require 'json'

require 'rack'
require 'rack/showexceptions'
require 'thin'
require 'data_mapper'
require 'omf_base/lobject'
require 'omf_base/load_yaml'

require 'omf-sfa/am/am_runner'
#require 'omf-sfa/am/am_manager'
#require 'omf-sfa/am/am_scheduler'

require 'omf_base/lobject'

module OMF::ProjectAuthority

  class Server
    # Don't use LObject as we haveb't initialized the logging system yet. Happens in 'init_logger'
    include OMF::Base::Loggable
    extend OMF::Base::Loggable

    def init_logger
      OMF::Base::Loggable.init_log 'server', :searchPath => File.join(File.dirname(__FILE__), 'server')

      @config = OMF::Base::YAML.load('config', :path => [File.dirname(__FILE__) + '/../../../etc/omf-project-authority'])[:project_authority]
    end

    def init_data_mapper(options)
      #@logger = OMF::Base::Loggable::_logger('am_server')
      #OMF::Base::Loggable.debug "options: #{options}"
      debug "options: #{options}"

      # Configure the data store
      #
      DataMapper::Logger.new(options[:dm_log] || $stdout, :info)
      DataMapper.setup(:default, options[:dm_db])

      require 'omf-sfa/resource'
      require 'omf/project_authority/resource'
      DataMapper::Model.raise_on_save_failure = true
      DataMapper.finalize
      DataMapper.auto_upgrade! if options[:dm_auto_upgrade]
    end


    def load_test_state(options)
      require 'omf-sfa/am/am-rest/rest_handler'
      OMF::SFA::AM::Rest::RestHandler.set_service_name("OMF Test Project Authority")

      require  'dm-migrations'
      DataMapper.auto_migrate!

      u1_uuid = UUIDTools::UUID.sha1_create(UUIDTools::UUID_DNS_NAMESPACE, 'adam')
      u1 = OMF::ProjectAuthority::Resource::User.create(name: 'adam',
                                        uuid: u1_uuid,
                                        email: 'adam@acme.com'
                                        )
      u2_uuid = UUIDTools::UUID.sha1_create(UUIDTools::UUID_DNS_NAMESPACE, 'bob')
      u2 = OMF::ProjectAuthority::Resource::User.create(name: 'bob',
                                        uuid: u2_uuid,
                                        email: 'bob@acme.com',
                                        )

      p1_uuid = UUIDTools::UUID.sha1_create(UUIDTools::UUID_DNS_NAMESPACE, 'projectA')
      p1 = OMF::ProjectAuthority::Resource::Project.create(name: 'projectA', uuid: p1_uuid)
      p2_uuid = UUIDTools::UUID.sha1_create(UUIDTools::UUID_DNS_NAMESPACE, 'projectB')
      p2 = OMF::ProjectAuthority::Resource::Project.create(name: 'projectB', uuid: p2_uuid)

      OMF::ProjectAuthority::Resource::ProjectMember.create(user: u1, project: p1)
      OMF::ProjectAuthority::Resource::ProjectMember.create(user: u2, project: p1)

      OMF::ProjectAuthority::Resource::ProjectMember.create(user: u2, project: p2)

    end

    def run(opts)
      opts[:handlers] = {
        # Should be done in a better way
        :pre_rackup => lambda {
        },
        :pre_parse => lambda do |p, options|
          p.on("--test-load-state", "Load an initial state for testing") do |n| options[:load_test_state] = true end
          p.on("--test-omf-am URL", "Top URL for Test OMF AM") do |n| options[:test_omf_am] = n end
          p.separator ""
          p.separator "Datamapper options:"
          p.on("--dm-db URL", "Datamapper database [#{options[:dm_db]}]") do |u| options[:dm_db] = u end
          p.on("--dm-log FILE", "Datamapper log file [#{options[:dm_log]}]") do |n| options[:dm_log] = n end
          p.on("--dm-auto-upgrade", "Run Datamapper's auto upgrade") do |n| options[:dm_auto_upgrade] = true end
          p.separator ""
        end,
        :pre_run => lambda do |opts|
          init_logger()
          init_data_mapper(opts)
          load_test_state(opts) if opts[:load_test_state]
        end
      }


      #Thin::Logging.debug = true
      require 'omf_base/thin/runner'
      OMF::Base::Thin::Runner.new(ARGV, opts).run!
    end
  end # class
end # module




