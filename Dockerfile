FROM ghcr.io/dynamixs-ai/ai-platform:latest

# Deploy artefact
RUN rm -r /opt/jboss/wildfly/standalone/deployments/*
# Deploy artefact
COPY ./target/*.war /opt/jboss/wildfly/standalone/deployments/

