require "rulers/version"
require "rulers/array"
require "rulers/routing"
require "rulers/util"
require "rulers/dependencies"
require "rulers/controller"
require "rulers/file_model"

module Rulers
  class Error < StandardError; end
  # Your code goes here...

  class Application
    def call(env)
      `echo debug > debug.txt`;
      begin
        case env['PATH_INFO']
        when'/favicon.ico'
          return [404, {"Content-Type" => "text/html"}, []]
        when "/"
          klass, act = HomeController, "index"
          r = get_content(env, klass, act)
          return [r.status, r.headers, [r.body].flatten] if r
        when "/home"
          return [302, {"location" => "/"}, []]
        when "/index"
          filename = File.join("app", "public", "index.html")
          content = File.read(filename)
        else
          klass, act = get_controller_and_action(env)
          r = get_content(env, klass, act)
          return [r.status, r.headers, [r.body].flatten] if r
        end
        [200, {"Content-Type" => "text/html"}, [content]]
      # rescue
        # [500, {"Content-Type" => "text/html"}, ["Internal Server Error"]]
      end
    end

    def get_content(env, klass, act)
      controller = klass.new(env)
      controller.send(act)
      r = controller.get_response
    end
  end
end
