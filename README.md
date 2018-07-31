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

# FAQ

Q: Why shiny?<br>
A: Since it is writen in Crystal
