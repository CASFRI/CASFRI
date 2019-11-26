## 7.0 ECO Attributes

Updated: 2019-08-08



Ecological attributes are generally not included or are incompletely recorded in typical forest inventories across Canada. Two attributes have been included for CAS: ecosite and wetland. These attributes are to be translated or derived for CAS from other attributes whenever possible.  



### cas_id

The attribute cas_id is an alpha-numeric identifier that is unique for each polygon within CAS database.

| cas_id                                                       | values        |
| :----------------------------------------------------------- | :------------ |
| CAS stand identification - unique number for each polygon within CAS | alpha numeric |



### wetland_type

The wetland classification scheme used for CAS follows the classes developed by the National Wetlands Working Group<sup>2</sup> and modified by Vitt and Halsey<sup>3,4</sup>. The scheme was further modified to take into account coastal and saline wetlands. The CAS wetland attribute is composed of four parts: wetland class, wetland vegetation modifier, wetland landform modifier, and wetland local modifier.  

Five major wetland classes are recognized based on wetland development from hydrologic, chemical, and biotic gradients that commonly have strong cross-correlations. Two of the classes; fen and bog, are peat-forming with greater than 40 cm of accumulated organics. The three non-peat forming wetland types are shallow open water, marsh (fresh or salt water), and swamp. A non-wetland class is also included. The Vegetation Modifier is assigned to a wetland class to describe the amount of vegetation cover. The Landform Modifier is a modifier label used when permafrost, patterning, or salinity are present. The Local Landform Modifier is a modifier label used to define the presence or absence of permafrost features or if vegetation cover is shrub or graminoid dominated.  

The detailed wetland table, CAS code set, and CAS translation rule set are presented in Appendix 14. Not many forest inventories across Canada provide a wetland attribute. Some inventories have complete or partial wetland attributes while others will need to have wetland classes derived from other attributes or ecosite information. The level of wetland detail that is possible to describe from a particular inventory database is dependent on the attributes that already exist. A rule set for each province or territory that identifies a method to derive wetland attributes using forest attributes or ecosite data is presented in Appendix 15. The wetland derivation may not be complete nor will it always be possible to derive or record all four wetland attributes in the CAS database. 

| wetland_type                                                 | values |
| :----------------------------------------------------------- | :----- |
| Bog - > 40 cm peat, receive water from precipitation only, low in nutrients and acid, open or wooded with sphagnum moss | B      |
| Fen - > 40 cm of peat, groundwater and runoff flow, mineral rich with mostly brown mosses, open, wooded or treed | F      |
| Swamp - woody vegetation with > 30 shrub cover or 6% tree cover. Mineral rich with periodic flooding and near permanent subsurface water. Various mixtures of mineral sediments and peat. | NA     |
| Marsh - emergent vegetation with < 30% shrub cover, permanent or seasonally inundated with nutrient rich water | M      |
| Shallow Open Water - freshwater lakes < 2 m depth            | O      |
| Tidal Flats - ocean areas with exposed flats                 | T      |
| Estuary - mixed freshwater/saltwater marsh areas             | E      |
| Wetland - no distinction of class                            | W      |
| Not Wetland - upland areas                                   | Z      |
| Blank - no value                                             | NA     |



### wet_veg_cover

| wet_veg_cover                                           | values |
| :------------------------------------------------------ | :----- |
| Forested - closed canopy > 70% tree cover               | F      |
| Wooded - open canopy > 6% to 70% tree cover             | T      |
| Open Non-Treed Freshwater - < 6% tree cover with shrubs | O      |
| Open Non-Treed Coastal - < 6% tree cover, with shrubs   | C      |
| Mud - no vegetation cover                               | M      |
| Blank - no value                                        | NA     |



### wet_landform_mod


| wet_landform_mod                    | values |
| :---------------------------------- | :----- |
| Permafrost Present                  | X      |
| Patterning Present                  | P      |
| No Permafrost or Patterning Present | N      |
| Saline or Alkaline Present          | A      |
| Blank - no value                    | NA     |



### wet_local_mod


| wet_local_mod                                        | values |
| :--------------------------------------------------- | :----- |
| Collapse Scar Present in permafrost area             | C      |
| Internal Lawn With Islands of Forested Peat Plateau  | R      |
| Internal Lawns Present (permafrost was once present) | I      |
| Internal Lawns Not Present                           | N      |
| Shrub Cover > 25%                                    | S      |
| Graminoids With Shrub Cover < 25%                    | G      |
| Blank - no value                                     | NA     |

  

<sup>2</sup>National Wetlands Working Group 1988. Wetlands of Canada. Ecological Land Classification Series No. 24.  

<sup>3</sup>Alberta Wetland Inventory Standards. Version 1.0. June 1977. L. Halsey and D. Vitt.  

<sup>4</sup> Alberta Wetland Inventory Classification System. Version 2.0. April 2004. Halsey, et. al.  

  

### ecosite  

Ecosites are site-level descriptions that provide a linkage between vegetation and soil/moisture and nutrient features on the site. The detailed ecosite table is presented in Appendix 16. A common attribute structure for ecosite is not provided for CAS because ecosite is not available for most forest inventories across Canada nor can it be derived from existing attributes. An ecosite field is included in CAS to accommodate inventories that do include ecosite data. The original inventory attribute value is captured in CAS. For example some codes:  Quebec = MS25S, Ontario = ES11 or 044 or S147N and Alberta = UFb1.2.    

| ecosite                                                      | values      |
| :----------------------------------------------------------- | :---------- |
| Ecosite - an area defined by a specific combination of site, soil, and | A-Z / 0-199 |
| vegetation characteristics as influenced by environmental factors. | NA          |
