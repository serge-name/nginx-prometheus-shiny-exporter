require "kemal"

class Fbr::Web

  def initialize(config : Config, ch_cmd : Channel(Bool), ch_data : Channel(String))
    Kemal.config.host_binding = config.web_host
    Kemal.config.port = config.web_port
    Kemal.config.powered_by_header = false
    Kemal.config.shutdown_message = false
    Kemal.config.logging = config.debug
    @ch_cmd = ch_cmd
    @ch_data = ch_data
  end

  def run
    serve_static false
    gzip true

    get "/metrics" do |env|
      @ch_cmd.send(true)
      @ch_data.receive
    end

    error 404 do |env|
      env.response.content_type = "text/plain"
      "404\n"
    end

    spawn do
      Kemal.run
    end
  end

end
