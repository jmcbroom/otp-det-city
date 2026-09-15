# OpenTripPlanner for Metro Detroit

A Docker-based setup for running OpenTripPlanner (OTP) with Metro Detroit transit data. This setup is designed for easy deployment to cloud platforms like Railway or Render.

## Quick Start (Local Development)

1. **Clone the repository**
   ```bash
   git clone https://github.com/jmcbroom/otp-det-city.git
   cd otp-det-city
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Optionally adjust JAVA_OPTS
   ```

3. **Start OpenTripPlanner**
   ```bash
   docker compose up
   ```

4. **Access OTP**
   - API: http://localhost:8080
   - Web Interface: http://localhost:8080/otp
   - API Documentation: http://localhost:8080/otp/routers/default

## Repository Structure

```
otp-det-city/
├── data/                       # Transit and map data
│   ├── build-config.json       # OTP build configuration
│   ├── router-config.json      # OTP runtime configuration
│   ├── ddot_gtfs_*.zip         # DDOT GTFS feed
│   ├── smart_gtfs_*.zip        # SMART GTFS feed
│   └── detroit_michigan.osm.pbf (downloaded during build)
├── Dockerfile                  # Container configuration
├── docker-compose.yml          # Local development setup
├── .env.example                # Environment variable template
└── README.md                   # This file
```

## Data Sources

### GTFS Feeds (Transit Data)

GTFS feed files are committed to this repository (in `data/`) and updated periodically:

- **SMART** - Suburban Mobility Authority for Regional Transportation
  - Covers Oakland, Macomb, and Wayne counties
  - File: `smart_gtfs_*.zip`

- **DDOT** - Detroit Department of Transportation
  - City of Detroit bus service
  - File: `ddot_gtfs_*.zip`

### OpenStreetMap Data

The OSM extract (`detroit_michigan.osm.pbf`, ~150 MB, bbox -84.158,41.723 to -82.375,43.168 — Detroit, Windsor, Ann Arbor, Flint) is **downloaded during the Docker build** from a release asset on this repository (`osm-2025-11-21`). It is too large to commit directly.

It was originally produced by Interline OSM Extracts, which stopped publishing city extracts in 2026. To refresh it: build a new `.pbf` for the same bounding box (e.g. `osmium extract` from Geofabrik's Michigan and Ontario downloads), upload it as a new release asset, and bump the `OSM_RELEASE` build arg in the `Dockerfile`.

## Configuration

### Environment Variables

Set these in your `.env` file:

```bash
# Optional: Java memory settings (adjust based on available RAM)
JAVA_OPTS=-Xmx4G
```

### Router Configuration

Edit `data/router-config.json` to customize:
- Walk speed and reluctance
- Transfer penalties
- Maximum walk distance
- Real-time updaters (GTFS-RT, GBFS)

### Build Configuration

Edit `data/build-config.json` to:
- Add/remove GTFS feeds
- Configure street and transit building

## Local Development

### Updating GTFS Data

1. Download new GTFS feed files
2. Move them to the `data/` directory
3. Update filenames in `data/build-config.json` if needed
4. Commit and push to trigger a new build
5. Restart the application: `docker compose restart`

### Viewing Logs

```bash
docker compose logs -f opentripplanner
```

### Stopping the Application

```bash
docker compose down
```

## Cloud Deployment

This repository is designed to deploy to PaaS platforms that support Docker.

### Recommended Platforms

- **Railway** (https://railway.app) - Recommended for simplicity
- **Render** (https://render.com)
- **DigitalOcean App Platform**

### Deployment Steps

1. Connect your GitHub repository to your chosen platform
2. Configure the domain to point to `otp.det.city` (or your preferred subdomain)
3. Deploy

The platform will automatically:
- Download the OSM extract from the GitHub release
- Build the Docker image
- Start the container
- Handle SSL/HTTPS with automatic certificate management

### Updating in Production

Simply push changes to the `main` branch:
```bash
git add data/
git commit -m "Update GTFS feeds"
git push origin main
```

Your platform will automatically detect the changes, rebuild, and redeploy.

## API Examples

### Plan a Trip
```bash
curl "http://localhost:8080/otp/routers/default/plan?fromPlace=42.3314,-83.0458&toPlace=42.3486,-83.0603&mode=TRANSIT,WALK"
```

### Get Stops
```bash
curl "http://localhost:8080/otp/routers/default/index/stops"
```

### Get Routes
```bash
curl "http://localhost:8080/otp/routers/default/index/routes"
```

## Real-time Features

The `router-config.json` includes real-time updaters:
- **GTFS-RT Alerts** - Service alerts and disruptions
- **GTFS-RT Trip Updates** - Real-time trip changes
- **GTFS-RT Vehicle Positions** - Live vehicle locations
- **GBFS** - Bike-share availability (MoGo)

## Troubleshooting

### Build Fails Downloading the OSM Extract

The Dockerfile fetches `detroit_michigan.osm.pbf` from a GitHub release on this repo (`OSM_RELEASE` build arg). Check that the release and its asset still exist. `curl -f` makes the build fail here rather than continue with a broken file and an empty street graph.

### Out of Memory

Increase the `JAVA_OPTS` value:
```bash
JAVA_OPTS=-Xmx6G
```

### Slow Build Times

Building the graph from scratch can take 10-30 minutes depending on data size and system resources. This is normal.

### Check Logs

```bash
docker compose logs opentripplanner
```

## Resources

- [OTP Documentation](https://docs.opentripplanner.org/)
- [OTP GitHub](https://github.com/opentripplanner/OpenTripPlanner)
- [GTFS Specification](https://gtfs.org/)
- [OpenStreetMap](https://www.openstreetmap.org/)

## License

This configuration is provided as-is for use with OpenTripPlanner.
OTP is licensed under LGPL. See https://github.com/opentripplanner/OpenTripPlanner for details.
