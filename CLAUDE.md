# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an OpenTripPlanner (OTP) deployment for Metro Detroit transit routing. It runs OTP in Docker with GTFS transit data from multiple regional agencies and OpenStreetMap data for the Detroit area.

## Common Commands

**Start the application locally:**
```bash
docker compose up
```

**Rebuild after changes:**
```bash
docker compose up --build
```

**View logs:**
```bash
docker compose logs -f opentripplanner
```

**Stop the application:**
```bash
docker compose down
```

## Architecture

- **OTP Container**: Based on `opentripplanner/opentripplanner:latest`, runs on ports 8080 (API) and 8081
- **Graph Building**: OTP builds a routing graph at container startup from GTFS + OSM data (`--build --serve`)
- **OSM Data**: Downloaded during Docker build from a GitHub release asset on this repo (`OSM_RELEASE` build arg in `Dockerfile`, default `osm-2025-11-21`). Interline's city extracts stopped being published in 2026.

## Data Files (in `data/`)

- **GTFS feeds**: `*_gtfs_*.zip` files for each transit agency (DDOT, SMART, QLine, LINQ, Transit Windsor, D2A2/DAX, TheRide, Flint MTA)
- **build-config.json**: Defines which GTFS feeds to include and the OSM extract filename
- **router-config.json**: Runtime routing parameters and real-time GTFS-RT/GBFS updaters

## Adding/Updating Transit Data

1. Download new GTFS zip file to `data/`
2. Add entry to `data/build-config.json` transit array with `source` (filename) and `feedId`
3. Optionally add GTFS-RT updaters to `data/router-config.json`
4. Rebuild: `docker compose up --build`

## Environment Variables

Optional in `.env`:
- `JAVA_OPTS` - Memory allocation (default `-Xmx4G`, increase for more feeds)

## API Endpoints

- Trip planning: `GET /otp/routers/default/plan?fromPlace=LAT,LON&toPlace=LAT,LON&mode=TRANSIT,WALK`
- Stops: `GET /otp/routers/default/index/stops`
- Routes: `GET /otp/routers/default/index/routes`
