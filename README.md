# Setting up Apache Kafka Connect in Kubernetes
The following repo shows how to setup a most basic version of Kafka Connect using the Apache Image.  Apache Kafka is a HIGHLY Active, Open Source project that is the underlying technology to most of the streaming solution on the internet. 


Kafka Connect is a tool for scalably and reliably streaming data between Apache Kafka and other systems. It makes it simple to quickly define connectors that move large collections of data into and out of Kafka. Kafka Connect can ingest entire databases or collect metrics from all your application servers into Kafka topics, making the data available for stream processing with low latency. An export job can deliver data from Kafka topics into secondary storage and query systems or into batch systems for offline analysis.

Kafka Connect features include:

* **A common framework for Kafka connectors** - Kafka Connect standardizes integration of other data systems with Kafka, simplifying connector development, deployment, and management
* **Distributed and standalone modes** - scale up to a large, centrally managed service supporting an entire organization or scale down to development, testing, and small production deployments

* **REST interface** - submit and manage connectors to your Kafka Connect cluster via an easy to use REST API

* **Automatic offset management** - with just a little information from connectors, Kafka Connect can manage the offset commit process automatically so connector developers do not need to worry about this error prone part of connector development
  
* **Distributed and scalable by default** - Kafka Connect builds on the existing group management protocol. More workers can be added to scale up a Kafka Connect cluster.
  
* **Streaming/batch integration**  - leveraging Kafka's existing capabilities, Kafka Connect is an ideal solution for bridging streaming and batch data systems



REF:  https://kafka.apache.org/documentation/

GIT:  https://github.com/apache/kafka



**The general pattern is:**
1.  Build a container image that includes Kafka + your connector plugins
2.  Deploy it as a K8s Deployment + Service
3.  Configure it to talk outbound to Confluent Cloud (SASL_SSL)
4.  Create connectors via the Connect REST API (or mount JSON and POST them)

<br /> <br />
For the Kubernetes portion we will build the following:
1.  **Secret** - for Confluent Cloud API key/secret + bootstrap info
2.  **ConfigMap** - for connect-distributed.properites 
3.  **Deployment** - for Kafka Connect workers
4.  **Service** - Expose the REST API on port 8083



## 1 - Generate the Container Image
The following steps will be used to generate an docker image that can be run on a kubernetes clsuter. 

1.  Copy any plugins desired to the **"/plugins"** folder. 
2.  Build and push the image
   
    ```bash
    docker build -t ghcr.io/cloud-focus-tech/kafka-connect-apache:0.0.1 .
    
    docker push ghcr.io/cloud-focus-tech/kafka-connect-apache:0.0.1
    ```
   

## 2 - Deploy the needed Kubernetes Assets

1. Create a Namespace for the Cluster
   ```bash
    kubectl create namespace kafka-connect-apache
    kubectl label ns kafka-connect-apache pod-security.kubernetes.io/enforce=privileged  
    kubectl label ns kafka-connect-apache pod-security.kubernetes.io/audit=privileged 
    kubectl label ns kafka-connect-apache pod-security.kubernetes.io/warn=privileged
   ```
2. Deploy the Kakfa Cluster Secrets
   ```bash
   kubectl -n kafka-connect-apache create secret generic ccloud-kafka \
    --from-literal=BOOTSTRAP_SERVERS='<CCLOUD_BOOTSTRAP>:9092' \
    --from-literal=KAFKA_API_KEY='<CCLOUD_KEY>' \
    --from-literal=KAFKA_API_SECRET='<CCLOUD_SECRET>'
   ```
3. Deploy the Configmap (for connect settings)
    ```bash
    kubectl apply -f connect-config.yaml
    ```
4. Deploy the Connect Cluster (Deployment and the Service)
    ```bash
    kubectl apply -f deploy.yaml
    ```
   
   


