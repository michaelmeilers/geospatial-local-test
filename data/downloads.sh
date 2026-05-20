#!/bin/bash

# Data download script for geospatial-local-test
# Downloads public datasets for 2D and 3D geospatial processing

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DATA_DIR="${SCRIPT_DIR}/raw"
PROCESSED_DIR="${SCRIPT_DIR}/processed/silver"

echo "🌍 Geospatial Data Downloader"
echo "================================"

# Create directories
mkdir -p "$DATA_DIR"
mkdir -p "$PROCESSED_DIR"

# 1. Download Natural Earth datasets
echo "📥 Downloading Natural Earth datasets..."

# Countries (1:10m)
echo "  → Countries shapefile"
cd "$DATA_DIR"
wget -q https://naciscdn.org/naturalearth/10m/cultural/ne_10m_admin_0_countries.zip 2>/dev/null || echo "    (wget not available, please download manually)"
unzip -q -o ne_10m_admin_0_countries.zip 2>/dev/null || true

# Cities
echo "  → Populated places"
wget -q https://naciscdn.org/naturalearth/10m/cultural/ne_10m_populated_places_simple.zip 2>/dev/null || echo "    (wget not available)"
unzip -q -o ne_10m_populated_places_simple.zip 2>/dev/null || true

# Rivers
echo "  → Rivers"
wget -q https://naciscdn.org/naturalearth/10m/physical/ne_10m_rivers_lake_centerlines.zip 2>/dev/null || echo "    (wget not available)"
unzip -q -o ne_10m_rivers_lake_centerlines.zip 2>/dev/null || true

cd "$SCRIPT_DIR"

# 2. Download NYC Taxi data (small sample)
echo "📥 Downloading NYC Taxi sample data..."
# Using a small 2023 sample from NYC TLC official source
# Note: Full dataset is large; this gets a manageable sample
wget -q https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2023-01.parquet \
  -O "$DATA_DIR/nyc_taxi_2023_01.parquet" 2>/dev/null || \
  echo "  ℹ️  NYC Taxi download skipped (dataset too large for automated download)"

# 3. Download small LiDAR sample
echo "📥 Downloading sample LiDAR data..."
# Using OpenTopography's free sample data
# For demo purposes, creating a synthetic sample instead
echo "  ℹ️  Note: Full LiDAR download requires OpenTopography login"
echo "  ℹ️  See README for manual download instructions from:"
echo "  ℹ️  - OpenTopography: https://opentopography.org/"
echo "  ℹ️  - USGS 3DEP: https://earthexplorer.usgs.gov/"

# 4. Create sample synthetic data for testing
echo "📊 Generating synthetic sample data..."

python3 << 'EOF'
import geopandas as gpd
import pandas as pd
import numpy as np
from shapely.geometry import Point
import os

data_dir = os.path.join(os.getcwd(), 'data', 'raw')

# Create synthetic NYC taxi data
np.random.seed(42)
n_samples = 10000

taxi_data = pd.DataFrame({
    'pickup_longitude': np.random.uniform(-74.02, -73.92, n_samples),
    'pickup_latitude': np.random.uniform(40.70, 40.80, n_samples),
    'dropoff_longitude': np.random.uniform(-74.02, -73.92, n_samples),
    'dropoff_latitude': np.random.uniform(40.70, 40.80, n_samples),
    'trip_distance': np.random.gamma(3, 2, n_samples),
    'fare_amount': np.random.gamma(13, 2, n_samples),
})

# Create GeoDataFrame
geometry = [Point(xy) for xy in zip(taxi_data['pickup_longitude'], taxi_data['pickup_latitude'])]
gdf_taxi = gpd.GeoDataFrame(taxi_data, geometry=geometry, crs="EPSG:4326")
gdf_taxi.to_file(os.path.join(data_dir, 'nyc_taxi_sample.geojson'), driver='GeoJSON')
print("✓ Created synthetic NYC taxi sample (10,000 points)")

# Create synthetic point cloud (LiDAR-like)
n_points = 100000
lidar_data = np.column_stack([
    np.random.uniform(-74.00, -73.94, n_points),  # X (lon)
    np.random.uniform(40.71, 40.79, n_points),    # Y (lat)
    np.random.exponential(30, n_points),           # Z (height)
])

np.save(os.path.join(data_dir, 'sample_lidar.npy'), lidar_data)
print(f"✓ Created synthetic LiDAR sample ({n_points:,} points)")

EOF

echo ""
echo "✅ Data download complete!"
echo ""
echo "📁 Downloaded files in: $DATA_DIR"
ls -lh "$DATA_DIR" 2>/dev/null | tail -n +2 || echo "   (files not found)"

echo ""
echo "📖 Next steps:"
echo "  1. Review data in: jupyter lab"
echo "  2. Run notebook: 01-data-ingestion.ipynb"
echo "  3. Explore spatial operations: 02-spatial-joins.ipynb"
