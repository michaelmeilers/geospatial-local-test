"""
Unit tests for spatial operations module.
"""

import pytest
import geopandas as gpd
import pandas as pd
import numpy as np
from shapely.geometry import Point, Polygon, box
import sys
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from spatial_ops import SpatialOps


@pytest.fixture
def sample_points():
    """Create sample point GeoDataFrame."""
    data = {
        'id': [1, 2, 3, 4, 5],
        'value': [10, 20, 30, 40, 50],
    }
    geometry = [
        Point(0, 0),
        Point(1, 1),
        Point(2, 2),
        Point(3, 3),
        Point(4, 4),
    ]
    return gpd.GeoDataFrame(data, geometry=geometry, crs="EPSG:4326")


@pytest.fixture
def sample_polygons():
    """Create sample polygon GeoDataFrame."""
    data = {
        'name': ['Region A', 'Region B'],
    }
    geometry = [
        box(0, 0, 2, 2),
        box(2, 2, 4, 4),
    ]
    return gpd.GeoDataFrame(data, geometry=geometry, crs="EPSG:4326")


class TestSpatialOps:
    """Test suite for SpatialOps class."""
    
    def test_spatial_join(self, sample_points, sample_polygons):
        """Test spatial join operation."""
        result = SpatialOps.spatial_join(sample_points, sample_polygons, how="inner")
        assert len(result) > 0
        assert 'name' in result.columns
    
    def test_buffer_operation(self, sample_points):
        """Test buffer operation."""
        buffered = SpatialOps.buffer_operation(sample_points, distance=0.5)
        assert len(buffered) == len(sample_points)
        assert buffered.geometry.area.sum() > sample_points.geometry.area.sum()
    
    def test_bounding_box_query(self, sample_points):
        """Test bounding box query."""
        result = SpatialOps.bounding_box_query(sample_points, minx=0, miny=0, maxx=2, maxy=2)
        assert len(result) >= 2
    
    def test_get_bounds(self, sample_points):
        """Test get_bounds function."""
        bounds = SpatialOps.get_bounds(sample_points)
        assert len(bounds) == 4
        assert bounds[0] <= bounds[2]


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
