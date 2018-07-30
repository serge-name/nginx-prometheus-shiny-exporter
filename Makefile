
run:
	crystal src/main.cr

clean:
	rm -vf bin/*

build:
	shards build

build_run: build
	bin/nginx-prometheus-shiny-exporter

.PHONY: spec

spec:
	@if tty -s; then \
	  crystal spec -v; \
	else \
	  crystal spec; \
	fi
