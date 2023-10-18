# redis_exporter
The following instruction contains setting up a redis prometheus exporter and monitor the redis performance for the robot-shop demo app.


## Setup with Helm
The setup uses Helm to create a redis ServiceMonitor.[prometheus-redis-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-redis-exporter) Prometheus will scrape the redis exporter pods to get the redis performance stats.

Helm Install:
```
helm install prometheus-redis-exporter-robotshop prometheus-community/prometheus-redis-exporter --namespace robot-shop --values prometheus_redis_robotshop_values.yaml
```

## Sample output from prometheus 
redis_commands_duration_seconds_total (target label is populated from the setting in prometheus_redis_robotshop_values.yaml)

```
redis_commands_duration_seconds_total{cmd="client", container="prometheus-redis-exporter", endpoint="redis-exporter", instance="redis://redis.robot-shop.svc.cluster.local:6379", job="prometheus-redis-exporter-robotshop", namespace="robot-shop", pod="prometheus-redis-exporter-robotshop-6fb7f57484-nx9mp", service="prometheus-redis-exporter-robotshop", target="redis.robot-shop.svc.cluster.local:6379"}
```