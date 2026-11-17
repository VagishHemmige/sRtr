# get_hrsa_optn_regions() rejects an unusable crs

    Code
      get_hrsa_optn_regions(crs = "not a crs")
    Condition
      Error in `get_hrsa_optn_regions()`:
      ! `crs` is not a coordinate reference system sf can use.
      i Pass an EPSG code such as `4326` or `5070`, or anything `sf::st_crs()` accepts.

