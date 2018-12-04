require "./config"
require "./fbr"
require "./sd_notify"

config = Config.new

collector = Fbr::Collector.new(config)
collector.run
Fbr::Syslog.new(config, collector.c_syslog).run
Fbr::Web.new(config, collector.c_web_cmd, collector.c_web_data).run

sd = SdNotify.new(config)
sd.ready

loop {
  sd.watchdog
  sd.sleep
}
