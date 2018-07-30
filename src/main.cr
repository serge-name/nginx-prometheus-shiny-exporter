require "./config"
require "./fbr"

config = Config.new

collector = Fbr::Collector.new(config)
collector.run
Fbr::Syslog.new(config, collector.c_syslog).run
Fbr::Web.new(config, collector.c_web_cmd, collector.c_web_data).run

loop { sleep(10) } # main loop: do nothing
