require "erubis"
require "rulers/file_model"

module Rulers
  class Controller
    include Rulers::Model
    def initialize(env)
      @env = env
    end

    def env
      @env
    end

    def render(view_name, locals={})
      filename = File.join("app", "views", controller_name, "#{view_name}.html.erb")
      content = File.read(filename)
      self.instance_variables.each do |var|
        locals = locals.merge(var => self.instance_variable_get(var))
      end
      Erubis::Eruby.new(content).result(locals.merge(:env => env))
    end

    def controller_name
      Rulers.to_underscore(self.class.to_s.gsub(/Controller$/, ""))
    end

    def request
      @request ||= Rack::Request.new(@env)
    end

    def params
      request.params
    end

    def response(text, status=200, headers={})
      raise "Already responded!" if @response
      a = [text].flatten
      @response = Rack::Response.new(a, status, headers)
    end

    def get_response
      @response
    end

    def render_response(*args)
      response(render(*args))
    end
  end
end