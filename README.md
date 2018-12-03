# Description

This application collects custom formatted log from [nginx](https://nginx.org) via Syslog, counts all the data and exports metrics to [Prometheus](https://prometheus.io/) server.

```
┌───────┐                     ┌─────────────────────────────────┐
│ nginx │───[ syslog/UDP ]───▸│ nginx-prometheus-shiny-exporter │
└───────┘                     └─────────────────────────────────┘
                                              ▴
                                              ║
                                           [ HTTP ]
                                              ║
                                              ▾
                                       ┌────────────┐
                                       │ Prometheus │
                                       └────────────┘
```

It works similar to [nginx_request_exporter](https://github.com/markuslindenberg/nginx_request_exporter) but written in [Crystal](https://crystal-lang.org).

# Status

`master` branch contains a production ready version. It is able to return a limited number of metrics. More ones will be added in future.

I use this application on Russian National Platform for Open Education https://openedu.ru

# Installation

1. [Install Crystal](https://crystal-lang.org/docs/installation/)
2. `apt install build-essential pkg-config zlib1g-dev libssl-dev`
3. `make build`

# Usage

Create a virtual host:

```
log_format collect_status 'stts|$host|$status';
log_format collect_time   'reqt|$host|$request_time';

server {
  listen 127.0.0.1:8877 default_server;

  access_log syslog:server=127.0.0.1:9467,tag=default collect_status;
  access_log syslog:server=127.0.0.1:9467,tag=default collect_time;

  location / {
    # …
  }

  location /special/ {
    access_log syslog:server=127.0.0.1:9467,tag=special collect_status;
    access_log syslog:server=127.0.0.1:9467,tag=special collect_time;
    # …
  }
}
```

Do several requests and check the metrics:

```
$ curl -s http://localhost:9467/metrics
# HELP nginx_request_status A metric
# TYPE nginx_request_status counter
nginx_request_status{host="127.0.0.1",tag="default",status="404"} 2
nginx_request_status{host="127.0.0.1",tag="default",status="499"} 3
nginx_request_status{host="127.0.0.1",tag="default",status="503"} 2
nginx_request_status{host="127.0.0.1",tag="default",status="204"} 1
nginx_request_status_ranges{host="127.0.0.1",tag="default",range="100-399"} 1
nginx_request_status_ranges{host="127.0.0.1",tag="default",range="400-498"} 2
nginx_request_status_ranges{host="127.0.0.1",tag="default",range="499"} 3
nginx_request_status_ranges{host="127.0.0.1",tag="default",range="500-599"} 2
# HELP nginx_request_time A metric
# TYPE nginx_request_time counter
nginx_request_time_sum{host="127.0.0.1",tag="default"} 0.0
nginx_request_time_count{host="127.0.0.1",tag="default"} 8
```

Add to prometheus a block like this:

```yaml
scrape_configs:
  - job_name: nginx
    scrape_interval: 5s
    scrape_timeout:  5s
    static_configs:
      - targets:
          - 192.0.2.8:9467
```

If you use [Grafana](https://grafana.com), a sample dashboard can be found in `contrib/` directory of the project.

# FAQ

Q: Why shiny?<br>
A: Because it is writen in Crystal
