

apt install crystal build-essential pkg-config zlib1g-dev libssl-dev




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
