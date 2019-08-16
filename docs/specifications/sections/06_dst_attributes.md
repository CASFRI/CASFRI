## 6.0 DST Attributes

Updated: 2019-08-09



### cas_id

The attribute cas_id is an alpha-numeric identifier that is unique for each polygon within CAS database.

| cas_id                                                       | values        |
| :----------------------------------------------------------- | :------------ |
| CAS stand identification - unique number for each polygon within CAS | alpha numeric |



### dist_type_1 - dist_type_3

Disturbance identifies the type of disturbance history that has occurred or is occurring within the polygon. The type of disturbance, the extent of the disturbance and the disturbance year, if known, may be recorded. The disturbance may be natural or human -caused. Up to three disturbance events can be recorded with the oldest event described first. Silviculture treatments have been grouped into one category and include any silviculture treatment or treatments recorded for a polygon. The detailed table, CAS codes, and CAS conversion rule set are presented in Appendix 13.  

<br>  

| dist_type_1, dist_type_2, dist_type_3 | values |
| :------------------------------------------------------------------------ | :-------------- |
| Cut - logging with known extent | CO |
| Partial Cut - portion of forest has been removed, extent known or unknown | PC |
| Burn - wildfires or escape fires | BU |
| Windfall - blow down | WF |
| Disease - root, stem, branch diseases | DI |
| Insect - root, bark, leader, or defoliation insects | IK |
| Flood - permanent flooding from blockage or damming | FL |
| Weather - ice, frost, red belt | WE |
| Slide - damage from avalanche, slump, earth or rock slides | SL |
| Other - unknown or other damage | OT |
| Dead Tops or Trees - dead or dying trees, cause unknown | DT |
| Silviculture Treatments - Planting, Thinning, Seed Tree | SI |



### dist_year_1 - dist_year_3  

Disturbance year is the year a disturbance event occurred. The disturbance year may be unknown. Three disturbance years can be identified, one for each disturbance event.    

| dist_year_1, dist_year_2, dist_year_3                      | values      |
| :--------------------------------------------------------- | :---------- |
| Disturbance Year - year that a disturbance event occurred. | 1900 - 2020 |



### dist_ext_upper_1 - dist_ext_upper_3

Disturbance extent provides an estimate of the proportion of the polygon that has been affected by the disturbance listed. Extent codes and  classes vary across Canada where they occur; therefore, CAS identifies upper and lower bounds for this category. Three disturbance extents can be identified, one for each disturbance event.    

| dist_ext_upper_1, dist_ext_upper_2, dist_ext_upper_3 | values |
| :--------------------------------------------------------------------------------------------------------------- | :-------------- |
| Upper bound of extent class | 10 - 100 |

  

### dist_ext_lower_1 - dist_ext_lower_3

Disturbance extent provides an estimate of the proportion of the polygon that has been affected by the disturbance listed. Extent codes and  classes vary across Canada where they occur; therefore, CAS identifies upper and lower bounds for this category. Three disturbance extents can be identified, one for each disturbance event.    

| dist_ext_lower_1, dist_ext_lower_2, dist_ext_lower_3 | values |
| :--------------------------------------------------- | :----- |
| Lower extent of extent class                         | 1 - 95 |



### layer  

Layer is an attribute related to stand structure that identifies which layer is being referred to in a multi-layered stand. The layer identification creates a link between each polygon attribute and the corresponding layer. Layer 1 will always be the top (uppermost) layer in the stand sequentially followed by Layer 2 and so on.  

The maximum number of layers recognized is nine. The uppermost layer may also be a veteran (V) layer. A veteran layer refers to a treed layer with a crown closure of 1 to 5 percent and must occur with at least one other layer; it typically includes the oldest trees in a stand.  

| layer                                                        | values   |
| :----------------------------------------------------------- | :------- |
| Identifies the number of vegetation or non vegetation layers assigned to a particular polygon. A maximum of 9 layers can be identified. | 1 - 9, V |

