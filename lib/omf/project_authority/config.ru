

REQUIRE_LOGIN = false

require 'rack/file'
class MyFile < Rack::File
  def call(env)
    c, h, b = super
    #h['Access-Control-Allow-Origin'] = '*'
    [c, h, b]
  end
end

require 'omf-sfa/resource/oresource'
OMF::SFA::Resource::OResource.href_resolver do |res, o|
  unless @http_prefix ||=
    @http_prefix = "http://#{Thread.current[:http_host]}"
  end
  # case rtype = res.resource_type.to_sym
  # when :user
    # "#@http_prefix/users/#{res.uuid}"
  # when :project
    # "#@http_prefix/projects/#{res.uuid}"
  # when :project_member
    # "#@http_prefix/project_members/#{res.uuid}"
  # else
    # "#@http_prefix/#{rtype}s/#{res.uuid}"
  # end
  "#@http_prefix/#{res.resource_type}s/#{res.uuid}"
end

opts = OMF::Base::Thin::Runner.instance.options

require 'omf-sfa/am/am-rest/session_authenticator'
use OMF::SFA::AM::Rest::SessionAuthenticator, #:expire_after => 10,
          :login_url => (REQUIRE_LOGIN ? '/login' : nil),
          :no_session => ['^/$', '^/login', '^/logout', '^/readme', '^/assets']


map '/users' do
  require 'omf/project_authority/user_handler'
  run opts[:user_handler] || OMF::ProjectAuthority::UserHandler.new(opts)
end

map '/projects' do
  require 'omf/project_authority/project_handler'
  run opts[:project_handler] || OMF::ProjectAuthority::ProjectHandler.new(opts)
end

map '/project_members' do
  require 'omf/project_authority/project_member_handler'
  run opts[:project_member_handler] || OMF::ProjectAuthority::ProjectMemberHandler.new(opts)
end


if REQUIRE_LOGIN
  map '/login' do
    require 'omf-sfa/am/am-rest/login_handler'
    run OMF::SFA::AM::Rest::LoginHandler.new(opts[:am][:manager], opts)
  end
end

map "/readme" do
  require 'bluecloth'
  s = File::read(File.dirname(__FILE__) + '/../../../README.md')
  frag = BlueCloth.new(s).to_html
  wrapper = %{
<html>
  <head>
    <title>OMF Project Authority API</title>
    <link href="/assets/css/default.css" media="screen" rel="stylesheet" type="text/css">
    <style type="text/css">
      circle.node {
        stroke: #fff;
        stroke-width: 1.5px;
      }

      line.link {
        stroke: #999;
        stroke-opacity: .6;
        stroke-width: 2px;

      }
</style>
  </head>
  <body>
%s
  </body>
</html>
}
  p = lambda do |env|
  puts "#{env.inspect}"

    return [200, {"Content-Type" => "text/html"}, [wrapper % frag]]
  end
  run p
end

map '/assets' do
  run MyFile.new(File.dirname(__FILE__) + '/../../../share/assets')
end

map "/" do
  handler = Proc.new do |env|
    req = ::Rack::Request.new(env)
    case req.path_info
    when '/'
      http_prefix = "http://#{env["HTTP_HOST"]}"
      toc = ['README', :users, :projects].map do |s|
        "<li><a href='#{http_prefix}/#{s.to_s.downcase}?_format=html&_level=0'>#{s}</a></li>"
      end
      page = {
        service: 'Project Authority',
        content: "<ul>#{toc.join("\n")}</ul>"
      }
      [200 ,{'Content-Type' => 'text/html'}, OMF::SFA::AM::Rest::RestHandler.render_html(page)]
    when '/favicon.ico'
      [301, {'Location' => '/assets/image/favicon.ico', "Content-Type" => ""}, ['Next window!']]
    else
      OMF::Base::Loggable.logger('rack').warn "Can't handle request '#{req.path_info}'"
      [401, {"Content-Type" => ""}, "Sorry!"]
    end
  end
  run handler
end

