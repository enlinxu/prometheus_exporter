# redis_exporter
The following instruction contains setting up a redis prometheus exporter and monitor the mysql performance for the robot-shop demo app.


## Setup with Helm
The setup uses Helm to create a redis ServiceMonitor.[prometheus-redis-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-redis-exporter) Prometheus will scrape the redis exporter pods to get the redis performance stats.

Helm Install:
```
helm install prometheus-redis-exporter-robotshop prometheus-community/prometheus-redis-exporter --namespace robot-shop --values prometheus_redis_robotshop_values.yaml
```
