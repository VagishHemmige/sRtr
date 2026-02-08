

#Downloads map available at https://www.arcgis.com/apps/mapviewer/index.html?url=https://gisportal.hrsa.gov/server/rest/services/Organs/OrganProcurementAndTransplantation_FS/FeatureServer/1&source=sd


url <- "https://gisportal.hrsa.gov/server/rest/services/Organs/OrganProcurementAndTransplantation_FS/FeatureServer/1/query?where=1%3D1&outFields=*&f=geojson"
centers <- st_read(url)
