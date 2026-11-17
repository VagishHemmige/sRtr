# get_hrsa_optn_regions() rejects an unusable crs

    Code
      get_hrsa_optn_regions(crs = "not a crs")
    Condition
      Error in `get_hrsa_optn_regions()`:
      ! `crs` is not a coordinate reference system sf can use.
      i Pass an EPSG code such as `4326` or `5070`, or anything `sf::st_crs()` accepts.

# get_hrsa_optn_regions(noncontiguous = 'shift') refuses another crs

    Code
      get_hrsa_optn_regions(crs = 4326, noncontiguous = "shift")
    Condition
      Error in `get_hrsa_optn_regions()`:
      ! `noncontiguous = "shift"` returns map positions in EPSG:5070 only.
      i Leave `crs` out, or use `noncontiguous = "include"` for real locations in another coordinate reference system.

