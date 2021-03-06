# Make topojson for CCTF maps
# Note: Alaska is split in the shapefile, it should be one district
ogr2ogr -where 'STATE="AK"' shp/Alaska.shp shp/JudicialDistricts/JudicialDistricts.shp
ogr2ogr shp/AlaskaMerged.shp shp/Alaska.shp -dialect sqlite -sql "SELECT ST_Union(geometry) AS geometry FROM Alaska" -overwrite

# Give it the needed properties after merge
ogrinfo shp/AlaskaMerged.shp -sql "ALTER TABLE AlaskaMerged ADD COLUMN DISTRICT_I string"
ogrinfo shp/AlaskaMerged.shp -sql "ALTER TABLE AlaskaMerged ADD COLUMN DISTRICT_N string"
ogrinfo shp/AlaskaMerged.shp -sql "ALTER TABLE AlaskaMerged ADD COLUMN DISTRICT_A string"
ogrinfo shp/AlaskaMerged.shp -dialect SQLite -sql "UPDATE AlaskaMerged SET DISTRICT_I = '0970'"
ogrinfo shp/AlaskaMerged.shp -dialect SQLite -sql "UPDATE AlaskaMerged SET DISTRICT_N = 'Alaska'"
ogrinfo shp/AlaskaMerged.shp -dialect SQLite -sql "UPDATE AlaskaMerged SET DISTRICT_A = 'AK'"

# 49 states minus Alaska
ogr2ogr -where 'STATE!="AK"' shp/NoAlaska.shp shp/JudicialDistricts/JudicialDistricts.shp

# Add Alaska back
ogr2ogr shp/JudicialDistricts_Final/JudicialDistricts_Final.shp shp/NoAlaska.shp
ogr2ogr -update -append shp/JudicialDistricts_Final/JudicialDistricts_Final.shp shp/AlaskaMerged.shp -nln JudicialDistricts_Final

# Added id property to shp and made csv with # of sentences by district in scripts/geoData.R

# Save topojson
# Add external property: number of sentences by juduical district
topojson -o data/judicialdistricts.json -e data/districtsentences.csv --id-property +id -p name=DISTRICT_N -p code=DISTRICT_A -p sentences=+sentences -- shp/JudicialDistricts_Final/JudicialDistricts_Final.shp


######### Facility complex point data
csv2geojson --lat latitude --lon longitude data/complexzips.csv > data/complexzips.geojson