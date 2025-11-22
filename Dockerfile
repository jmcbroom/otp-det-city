FROM opentripplanner/opentripplanner:latest

USER root

# Install curl (supports both Debian/Ubuntu and Alpine based images)
RUN (apt-get update && apt-get install -y curl) || (apk add --no-cache curl)

# Copy configuration and data files into the image first
COPY ./data /var/opentripplanner

# Build argument for the API token
ARG INTERLINE_API_TOKEN

# Download OSM data (this happens after copying data files)
RUN curl -L -o /var/opentripplanner/detroit_michigan.osm.pbf \
    "https://app.interline.io/osm_extracts/download_latest?string_id=detroit_michigan&data_format=pbf&api_token=${INTERLINE_API_TOKEN}"

# Set memory limit (Adjust based on your PaaS plan)
ENV JAVA_OPTS=-Xmx4G

# Build the graph and serve it
CMD ["--build", "--serve", "/var/opentripplanner"]
