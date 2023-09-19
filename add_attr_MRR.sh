#!/bin/bash
#add_attr_MRR.sh
NC_file=$1

#dat=$(date --utc -I)
ncatted -O -h \
  -a title,global,c,c,"MRR-2 data file" \
  -a description,global,m,c,"Micro-Rain-Radar data reprocessed with RaProM_38.py" \
  -a Conventions,global,c,c,"CF-1.8, ACDD-1.3" \
  -a institution,global,c,c,"Geophysical Institute, University of Bergen, Norway" \
  -a creator_name,global,c,c,"Stephan Kral" \
  -a creator_email,global,c,c,"Stephan.Kral@uib.no" \
  -a creator_orcid,global,c,c,"orcid: 0000-0002-7966-8585" \
  -a dataset_version,global,c,c,"1.0" \
  -a instrument,global,c,c,"Micro Rain Radar (MRR-2)" \
  -a instrument_manufacturer,global,c,c,"Metek GmbH, Germany" \
  -a creation_note,global,c,c,"Created with modified version of RaProM_38.py, by Albert Garcia Benadi (orcid: 0000-0002-5560-4392)" \
  -a software_citation,global,c,c,"Garcia-Benadi, A.; Bech, J.; Gonzalez, S.; Udina, M.; Codina, B.; Georgis, J.-F. Precipitation Type Classification of Micro Rain Radar Data Using an Improved Doppler Spectral Processing Methodology. Remote Sens. 2020, 12, 4113. https://doi.org/10.3390/rs12244113" \
  -a service_version,global,c,c,"6.0.0.6" \
  -a instrument_sampling_rate,global,c,c,"125 kHz" \
  -a height_resolution,global,c,c,"100 m" \
  -a geospatial_bounds,global,c,c,"POINT ((60.3837N 5.3318E))" \
  -a geospatial_bounds_crs,global,c,c," " \
  -a geospatial_lat_max,global,c,c,"60.3837" \
	-a geospatial_lat_min,global,c,c,"60.3837" \
	-a geospatial_lon_max,global,c,c,"5.3318" \
	-a geospatial_lon_min,global,c,c,"5.3318" \
  -a keywords,global,c,c,"radar, ground-based remote sensing, precipitation, observations, atmospheric profiles" \
	-a license,global,c,c,"The current version of the data is for internal use until it is published." \
	-a references,global,c,c," " \
  -a doi,global,c,c," " \
  -a cf_role,"time_utc",c,c,"profile_id" \
  -a cf_role,"Height",c,c,"timeseries_id" \
  -a summary,global,c,c,"MRR2 data... " \
  -a id,global,c,c,"doi: " \
   $NC_file
   # -a naming_authority,global,c,c" " \
   # -a processing_level,global,c,c" " \
   # -a commen,global,c,c" " \
   # -a acknowledgment,global,c,c" " \
   # -a project,global,c,c" " \
   # -a publisher_name,global,c,c" " \
   # -a publisher_email,global,c,c" " \
   # -a publisher_url,global,c,c" " \
