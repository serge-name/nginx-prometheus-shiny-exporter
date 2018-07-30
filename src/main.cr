require "./fbr"

collector = Fbr::Collector.new
collector.run
Fbr::Syslog.new("127.0.0.1", 10019, collector.c_syslog).run
Fbr::Web.new("127.0.0.1", 10018, collector.c_web_cmd, collector.c_web_data).run

loop { sleep(10) } # main loop: do nothing
