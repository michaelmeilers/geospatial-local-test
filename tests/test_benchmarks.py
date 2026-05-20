"""
Performance benchmark tests for geospatial operations.
"""

import pytest
import geopandas as gpd
import pandas as pd
import numpy as np
from shapely.geometry import Point, box
import sys
from pathlib import Path
import time

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from spatial_ops import SpatialOps


class TestBenchmarks:
    """Benchmark tests for geospatial operations."""
    
    @pytest.fixture
    def large_points(self):
        """Create large point dataset (100K points)."""
        np.random.seed(42)
        n = 100000
        data = {
            'id': range(n),
            'value': np.random.rand(n),
        }
        geometry = [
            Point(np.random.uniform(-74, -73), np.random.uniform(40, 41))
            for _ in range(n)
        ]
        return gpd.GeoDataFrame(data, geometry=geometry, crs="EPSG:4326")
    
    def test_spatial_join_benchmark(self, benchmark, large_points):
        """Benchmark spatial join performance."""
        large_polygons = gpd.GeoDataFrame(
            {'region_id': range(100)},
            geometry=[box(-74, 40, -73, 41) for _ in range(100)],
            crs="EPSG:4326"
        )
        
        def run_join():
            return SpatialOps.spatial_join(large_points, large_polygons, how="inner")
        
        result = benchmark(run_join)
        assert len(result) > 0


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--benchmark-only"])
