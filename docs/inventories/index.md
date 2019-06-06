---
title: "Inventories"
output:
  html_document:
    keep_md: yes
---

Welcome to the CASFRI 5.0 inventories translation pages.

<br>

## Documentation

The docs menu includes reference documents specifying the CASFRI standard. Currently, one document is available:

  * CAS Specification - converted from the original 2011 Cosco document to markdown format for easy updating.

<br>

## Inventories

The four menu items (AB06, AB16, BC08, NB01) include information on the procedure for translating the raw inventory data to the CASFRI standard. Under each menu are 6 items, one for each category of attribute (HDR, CAS, LYR, NFL, DST, ECO). By selecting on one of the items, you will see the current progress on understanding and converting each attribute to the standard. For many of the attributes, there is also some R code that was used to test the procedure while creating the CSV translation tables. Each attribute is summarized in raw form (RAWFRI tab) and translated form (CASFRI tab).

  * BC08 - in progress
  * AB06 - not yet available
  * AB16 - not yet available
  * NB01 - not yet available

<br>

## CAS05 Schema


hdr                     cas                 lyr                   nfl                   dst                eco              
----------------------  ------------------  --------------------  --------------------  -----------------  -----------------
HEADER_ID               CAS_ID              CAS_ID                CAS_ID                CAS_ID             CAS_ID           
JURISDICTION            ORIG_STAND_ID       SOIL_MOIST_REG        SOIL_MOIST_REG        DIST_1             WETLAND_TYPE     
OWNER_TYPE              STAND_STRUCTURE     STRUCTURE_PER         STRUCTURE_PER         DIST_YR_1          WET_VEG_COVER    
OWNER_NAME              NUM_OF_LAYERS       LAYER                 LAYER                 DIST_EXT_UPPER_1   WET_LANDFORM_MOD 
INVENTORY_TYPE          IDENTIFICATION_ID   LAYER_RANK            LAYER_RANK            DIST_EXT_LOWER_1   WET_LOCAL_MOD    
INVENTORY_VERSION       MAP_SHEET_ID        CROWN_CLOSURE_UPPER   CROWN_CLOSURE_UPPER   DIST_2             ECO_SITE         
INVENTORY_MANUAL        GIS_AREA            CROWN_CLOSURE_LOWER   CROWN_CLOSURE_LOWER   DIST_YR_2                           
SOURCE_DATA_FORMAT      GIS_PERIMETER       HEIGHT_UPPER          HEIGHT_UPPER          DIST_EXT_UPPER_2                    
ACQUISITION_DATE        INVENTORY_AREA      HEIGHT_LOWER          HEIGHT_LOWER          DIST_EXT_LOWER_2                    
DATA_TRANSFER           PHOTO_YEAR          PRODUCTIVE_FOR        NAT_NON_VEG           DIST_3                              
RECEIVED_FROM                               SPECIES_1             NON_FOR_ANTH          DIST_YR_3                           
CONTACT_INFO                                SPECIES_PER_1         NON_FOR_VEG           DIST_EXT_UPPER_3                    
DATA_AVAILABILITY                           SPECIES_2                                   DIST_EXT_LOWER_3                    
REDISTRIBUTION                              SPECIES_PER_2                               LAYER                               
PERMISSION                                  SPECIES_3                                                                       
LICENSE_AGREEMENT                           SPECIES_PER_3                                                                   
SOURCE_DATA_PHOTOYEAR                       SPECIES_4                                                                       
PHOTOYEAR_START                             SPECIES_PER_4                                                                   
PHOTOYEAR_END                               SPECIES_5                                                                       
                                            SPECIES_PER_5                                                                   
                                            SPECIES_6                                                                       
                                            SPECIES_PER_6                                                                   
                                            SPECIES_7                                                                       
                                            SPECIES_PER_7                                                                   
                                            SPECIES_8                                                                       
                                            SPECIES_PER_8                                                                   
                                            SPECIES_9                                                                       
                                            SPECIES_PER_9                                                                   
                                            SPECIES_10                                                                      
                                            SPECIES_PER_10                                                                  
                                            ORIGIN_UPPER                                                                    
                                            ORIGIN_LOWER                                                                    
                                            SITE_CLASS                                                                      
                                            SITE_INDEX                                                                      
