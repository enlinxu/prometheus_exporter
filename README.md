# prometheus_exporter
The repository contains set up for Prometheus Exporters against a demo app


## Demo App
### [Robot-shop](https://github.com/instana/robot-shop)
Created by Instana, Stan's Robot Shop is a sample microservice application you can use as a sandbox to test and learn containerised application orchestration and monitoring techniques. It is not intended to be a comprehensive reference example of how to write a microservices application, although you will better understand some of those concepts by playing with Stan's Robot Shop. To be clear, the error handling is patchy and there is not any security built into the application.
This sample microservice application has been built using these technologies:

NodeJS (Express)
Java (Spring Boot)
Python (Flask)
Golang
PHP (Apache)
MongoDB
Redis
MySQL (Maxmind data)
RabbitMQ
Nginx
AngularJS (1.x)

To install 

```
$ kubectl create ns robot-shop
$ helm install robot-shop --namespace robot-shop .
```

