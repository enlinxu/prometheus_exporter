#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <namespace>"
    exit 1
fi

NAMESPACE=$1

echo "Searching for MySQL services in namespace: ${NAMESPACE}..."

# Get the MySQL service name(s) within the provided namespace
MYSQL_SERVICES=$(kubectl get svc -n $NAMESPACE -l service=mysql -o jsonpath='{.items[*].metadata.name}')

if [ -z "$MYSQL_SERVICES" ]; then
    echo "No MySQL services found in namespace: ${NAMESPACE}. Exiting."
    exit 0
fi

echo "Found MySQL services: $MYSQL_SERVICES"

for MYSQL_SERVICE in $MYSQL_SERVICES; do
    # Making an assumption about how the exporter pods are named or labeled in relation to the MySQL services they monitor.
    # For example, if each exporter pod has a label that matches the MySQL service name:
    EXPORTER_POD=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/instance=prometheus-mysql-exporter -o jsonpath="{.items[0].metadata.name}")

    if [ -z "$EXPORTER_POD" ]; then
        echo "No exporter pod found for MySQL service: ${MYSQL_SERVICE}. Skipping."
        continue
    fi

    echo "Annotating exporter pod ${EXPORTER_POD} with MySQL service ${MYSQL_SERVICE}.${NAMESPACE}.svc.cluster.local:3306..."

    # Annotate the exporter pod with the MySQL service name
    kubectl annotate pod $EXPORTER_POD -n $NAMESPACE mysqlservicename=${MYSQL_SERVICE}.${NAMESPACE}.svc.cluster.local:3306
done

echo "Finished annotating pods in namespace: ${NAMESPACE}."