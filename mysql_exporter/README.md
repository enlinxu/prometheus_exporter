# mysql_exporter
The following instruction contains setting up a mysql prometheus exporter and monitor the mysql performance for the robot-shop demo app.


## Setup with Helm
The setup uses Helm to create a mysql ServiceMonitor.[prometheus-mysql-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-mysql-exporter) Prometheus will scrape the mysql exporter pods to get the mysql performance stats.

Helm Install:
```
helm install prometheus-mysql-exporter prometheus-community/prometheus-mysql-exporter --namespace robot-shop --values prometheus_mysql_robotshop_values.yaml
```

prometheus_mysql_robotshop_values:
```
service:
  port: 9104
  annotations:
    prometheus.io/port: "9104"
    prometheus.io/scrape: "true"

mysql:
  host: mysql  # Assuming that the MySQL service name is "mysql". Update if different.
  user: "shipping"
  pass: "secret"
  db: "cities"
  port: 3306

serviceMonitor:
  enabled: true
  # If your Prometheus is looking for a specific label, you might need to specify it. For example:
  # labels:
  #   release: prometheus
  # Adjust accordingly based on your Prometheus setup.
  relabelings:
    - sourceLabels: [__meta_kubernetes_pod_annotation_mysqlservicename]
      targetLabel: server
```

Notes:
1. The service specifies the port of mysql exporter port [9104](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-mysql-exporter), and set promtheus scrape to true.
2. The mysql part is the connection credential for the mysql DB for [Robot-Shop](https://github.com/instana/robot-shop/blob/55292e2199f2fb00a165b1f7d3045fe7f8922038/mysql/Dockerfile)
3. The serviceMonitor part is important. First it enables the serviceMonitor. The most important thing is the relabeling. By default, the output of the prometheus query will only contain the information about the exporter pods. The relabeling will allow us to add a new label called server, which uses the value of annotation mysqlservicename, which will be populated on the exporter pod in the next step.

## Annotate the mysql exporter pod
Annotate the exporter pod with the following command:
```
kubectl annotate pod <mysql_exporter_pod_name> mysqlservicename=mysql.robot-shop.svc.cluster.local:3306 -nrobot-shop
```

Or, use the included mysql_annotation_ns.sh, with the parameter of the mysql service namespace.
```
chmod +x mysql_annotation_ns.sh
./mysql_annotation_ns.sh robot-shop
```

## FAQ

### Q: I see failed to connect to the database in the mysql exporter pod log.
Answer: The logs indicate that the shipping MySQL user doesn't have sufficient privileges to access certain metrics. To resolve these errors, you'll need to grant additional privileges to this user.
However, granting additional privileges should be done cautiously, especially in a production environment. Make sure to understand the implications and test any changes in a non-production environment first.

To fix it for the demo app only.
```
kubectl exec -it <mysql-pod-name> -- mysql -uroot
```

Once connected, execute the following:
```
GRANT ALL PRIVILEGES ON *.* TO 'shipping'@'%';
FLUSH PRIVILEGES;
```

After granting the privileges using the root account, the shipping user should have the necessary permissions, and the MySQL exporter should function correctly without any privilege-related errors.


### Q: Now I don't see the errors in the exporter log, but I still don't see the mysql-exporter target in the prometheus Target configuration
Answer: ServiceMonitor Verification: Ensure that your Prometheus setup is set to watch the robot-shop namespace for ServiceMonitor resources. Depending on your setup, this might be set in a Prometheus custom resource or directly in the Prometheus configuration. 

Make sure your prometheus instance has the following sample setup:
```
  serviceMonitorNamespaceSelector:
    matchExpressions:
    - key: kubernetes.io/metadata.name
      operator: In
      values:
      - monitoring
      - robot-shop
```

### Q: Now I see it appears in the Target and being scrapped. But I don't see the extra server label
Answer: Annotation Presence: Ensure that the annotation (mysqlservicename) exists on the MySQL exporter pod in your local environment, just as it does in your other environment. You can verify this using:
```
kubectl get pod <exporter-pod-name> -n <namespace> -o=jsonpath='{.metadata.annotations.mysqlservicename}'
```

Correct Relabeling Configuration: Ensure that the ServiceMonitor has the correct relabeling configuration for the annotation in your local environment. It should look something like this:
```
relabelings:
- action: replace
  sourceLabels:
  - __meta_kubernetes_pod_annotation_mysqlservicename
  targetLabel: server
```

Prometheus Configuration: Ensure that Prometheus is actually using the correct ServiceMonitor and hasn't cached an older version. You can view the generated Prometheus configuration by accessing the Prometheus UI, then clicking on "Status" and selecting "Configuration". This will show the runtime configuration that Prometheus is using. Look for the job corresponding to your MySQL exporter and verify that the relabeling rules are present.

Prometheus Reload: Sometimes, a configuration change might not be picked up immediately. You can try reloading Prometheus by sending a SIGHUP signal to the Prometheus process. If you're running Prometheus inside Kubernetes, you can also try restarting the Prometheus pod.

