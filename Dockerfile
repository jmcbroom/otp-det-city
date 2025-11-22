FROM opentripplanner/opentripplanner:latest

USER root

# Install curl (supports both Debian/Ubuntu and Alpine based images)
RUN (apt-get update && apt-get install -y curl) || (apk add --no-cache curl)

# Copy the new entrypoint script and make it executable
COPY ./entrypoint.sh /var/opentripplanner/entrypoint.sh
RUN chmod +x /var/opentripplanner/entrypoint.sh

# Copy configuration and data files into the image first
COPY ./data /var/opentripplanner

# Build argument for the API token
ARG INTERLINE_API_TOKEN

# Download OSM data (this happens after copying data files)
RUN curl -L -o /var/opentripplanner/detroit_michigan.osm.pbf \
    "https://app.interline.io/osm_extracts/download_latest?string_id=detroit_michigan&data_format=pbf&api_token=${INTERLINE_API_TOKEN}"

# Set working directory
WORKDIR /var/opentripplanner

# Set memory limit (Adjust based on your PaaS plan)
ENV JAVA_OPTS=-Xmx4G

# Build the graph and serve it. The base image's entrypoint will correctly
# interpret these arguments.
CMD ["--build", "--serve"]
