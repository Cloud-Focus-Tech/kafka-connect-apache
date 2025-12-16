FROM apache/kafka:latest

USER root

# Where Kafka Connect will look for connector plugins
ENV CONNECT_PLUGIN_PATH="/opt/kafka/plugins"

RUN mkdir -p /opt/kafka/plugins

# Copy any connector plugins into the image
COPY plugins/ /opt/kafka/plugins/

# Expose Connect REST
EXPOSE 8083

# Run distributed worker
CMD ["/opt/kafka/bin/connect-distributed.sh", "/opt/kafka/config/connect-distributed.properties"]
USER kafka