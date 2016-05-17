import numpy as np
import os
from osgeo import gdal

def create_mask_from_vector(vector_path, cols, rols, geo_transform, projection, target_value=1):
	"""Rasterize vector"""
	data_source = gdal.Open(vector_path, gdal.OF_VECTOR)
	layer = data_source.GetLayer(0)
	driver = gdal.GetDriverByName('MEM')
	target_ds = driver.Create('', cols, rows, 1, gdal.GDT_UInt16)
	target_ds.SetProjection(projection)
	gdal.RasterizeLayer(target_ds, [1], layer, burn_values=[target_value])
	return target_ds
