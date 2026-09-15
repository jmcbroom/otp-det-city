# Pinned: 2.10.0 and the `latest` dev snapshots have an open bug where
# `--build --serve` maps the Raptor transit data before the graph is built, so
# every transit search fails (opentripplanner/OpenTripPlanner#7948). 2.9.0 is
# the last release that builds and serves in one run. If moving past it, either
# wait for the fix or split into `--build --save` + `--load --serve`.
FROM opentripplanner/opentripplanner:2.9.0

USER root

# Install curl (supports both Debian/Ubuntu and Alpine based images)
RUN (apt-get update && apt-get install -y curl) || (apk add --no-cache curl)

# Copy the new entrypoint script and make it executable
COPY ./entrypoint.sh /var/opentripplanner/entrypoint.sh
RUN chmod +x /var/opentripplanner/entrypoint.sh

# Copy configuration and data files into the image first
COPY ./data /var/opentripplanner

# OSM extract, served as a release asset on this repo (149 MB, too big to
# commit). Interline's city extracts stopped being published in 2026; see
# README. -f makes a failed download fail the build instead of leaving an
# error page where the .pbf should be.
ARG OSM_RELEASE=osm-2025-11-21
RUN curl -fL -o /var/opentripplanner/detroit_michigan.osm.pbf \
    "https://github.com/jmcbroom/otp-det-city/releases/download/${OSM_RELEASE}/detroit_michigan.osm.pbf"

# Set working directory
WORKDIR /var/opentripplanner

# Set memory limit (Adjust based on your PaaS plan)
ENV JAVA_OPTS=-Xmx6G

# Build the graph and serve it. The base image's entrypoint will correctly
# interpret these arguments.
CMD ["--build", "--serve"]
