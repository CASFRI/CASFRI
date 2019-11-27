## 4.0 LYR Attributes

Updated: 2019-11-28



### cas_id  

The attribute **cas_id** is an alpha-numeric identifier that is unique for each polygon within CAS database. It is a concatenation of attributes containing the following sections:

- Inventory id e.g., AB06
- Source filename i.e., name of shapefile or geodatabase
- Map ID or some other within inventory identifier; if available, map sheet id
- Polygon ID linking back to the source polygon (needs to be checked for uniqueness)
- Cas id - ogd_fid is added after loading ensuring all inventory rows have a unique identifier

| cas_id                                                       | values        |
| :----------------------------------------------------------- | :------------ |
| CAS stand identification - unique string for each polygon within CAS | alpha numeric |

Notes:

- Issue: https://github.com/edwardsmarc/CASFRI/issues/214 



### structure_per

The attribute **structure_per** is assigned when a horizontal structured polygon is identified. It is used with horizontal stands and identifies the percentage of stand area, assigned in 10% increments, attributed by each stratum within the entire polygon and must add up to 100%. Any number of horizontal strata can be described per horizontal polygon.

| structure_per                                                | values  |
| :----------------------------------------------------------- | :------ |
| Used with horizontal stands to identify the percentage, in 10% increments, strata within the polygon. Must add up to 100%. Only two strata represented by each homogeneous descriptions are allowed per polygon. Value = 100 when no horizontal structure. | 1 - 100 |

Notes:

- Only occurs when **stand_structure** = "H"
- When **stand_structure** != "H", then **structure_per** = 100
- Applies to the following inventories: AB, NB, NT
- How does this attribute differ for non-forested (NFL) polygons?
- See issue: https://github.com/edwardsmarc/CASFRI/issues/178 



### structure_range

The attribute **structure_range** is assigned when a complex structured polygon is identified. It is used with horizontal stands and identifies the percentage of stand area, assigned in 10% increments, attributed by each stratum within the entire polygon and must add up to 100%. Any number of horizontal strata can be described per horizontal polygon.

| structure_range                                              | values |
| :----------------------------------------------------------- | :----- |
| Measures the height range (m) around the midpoint height of the stand. It is calculated as the difference between the mean or median heights of the upper and lower layers within the complex stand. | 1 - 9  |

Notes:

- Only occurs when **stand_structure** = "C"
- Applies to the following inventories: AB, NB, NT
- How does this attribute differ for non-forested (NFL) polygons?



### layer

Layer is an attribute related to stand structure that identifies which layer is being referred to in a multi-layered stand. The layer identification creates a link between each polygon attribute and the corresponding layer. Layer 1 will always be the top (uppermost) layer in the stand sequentially followed by Layer 2 and so on. The maximum number of layers recognized is nine. The uppermost layer may also be a veteran (V) layer. A veteran layer refers to a treed layer with a crown closure of 1 to 5 percent and must occur with at least one other layer; it typically includes the oldest trees in a stand.

| layer                                                        | values   |
| :----------------------------------------------------------- | :------- |
| Identifies the number of vegetation or non vegetation layers assigned to a particular polygon. A maximum of 9 layers can be identified. | 1 - 9, V |



### layer_rank

Layer Rank value is an attribute related to stand structure and refers to layer importance for forest management planning, operational, or silvicultural purposes. When a Layer Rank is not specified, layers can be sorted in order of importance by layer number.  

| layer_rank                                                   | values |
| :----------------------------------------------------------- | :----- |
| Layer Rank - value assigned sequentially to layer of importance. Rank 1 is the most important layer followed by Rank 2, etc. | 1 - 9  |

  

### soil_moist_reg  

Soil moisture regime describes the available moisture supply for plant growth over a period of several years. Soil moisture regime is influenced by precipitation, evapotranspiration, topography, insolation, ground water, and soil texture. The CAS soil moisture regime code represents the similarity of classes across Canada. *The detailed soil moisture regime table and CAS conversion is presented in Appendix 4*.  

| soil_moist_reg                                                   | values |
| :----------------------------------------------------------- | :----- |
| Dry - Soil retains moisture for a negligible period following precipitation with very rapid drained substratum.  | D |
| Mesic - Soils retains moisture for moderately short to short periods following precipitation with moderately well drained substratum. | F |
| Moist - Soil retains abundant to substantial moisture for much of the growing season with slow soil infiltration. |  M |
| Wet - Poorly drained to flooded where the water table is usually at or near the surface, or the land is covered by shallow water. | W |
| Aquatic - Permanent deep water areas characterized by hydrophytic vegetation (emergent) that grows in or at the surface of water. | A |



### crown_closure 

Crown closure is an estimate of the percentage of ground area covered by vertically projected tree crowns, shrubs, or herbaceous cover. Crown closure is usually estimated independently for each layer.Crown closure is commonly represented by classes and differs across Canada therefore, CAS recognizes an upper and lower percentage bound for each class. The detailed crown closure table is presented in Appendix 5.  

| crown_closure_upper, crown_closure_lower    | values |
| :------------------------------------------------- | :-------------- |
| Upper Bound - upper bound of a crown closure class | 0 - 100         |
| Lower Bound - lower bound of a crown closure class | 0 - 100         |



### height  

Stand height is based on an average height of leading species of dominant and co-dominant heights of the vegetation layer and can represent trees, shrubs, or herbaceous cover. Height can be represented by actual values or by height class and its representation is variable across Canada; therefore, CAS will use upper and lower bounds to represent height. The detailed height table is presented in Appendix 6. 

| height_upper, height_lower             | values |
| :------------------------------------------ | :-------------- |
| Upper Bound - upper bound of a height class | 0 - 100         |
| Lower Bound - lower bound of a height class | 0 - 100         |



### productive_for  

Unproductive forest is forest land not capable of producing trees for forest operations. They are usually wetlands, very dry sites, exposed sites, rocky sites, higher elevation sites, or those sites with shallow or poor soils. The detailed table, CAS codes, and conversion rule sets are presented in Appendix 12.  

| productive_for | values |
| :-------------------------------------------------------------- | :-------------- |
| Treed Muskeg - treed wetland sites| TM |
| Alpine forest - high elevation forest usually above 1800 m | AL |
| Scrub Deciduous - scrub deciduous trees on poor sites | SD |
| Scrub Coniferous - scrub coniferous trees on poor sites | SC |
| Non Productive Forest - poor forest types on rocky or wet sites | NP |
| Productive Forest - any other forest | P|

Notes:

- This attribute needs an overhaul.



### species

Species composition is the percentage of each tree species represented within a forested polygon by layer. Species are listed in descending order according to their contribution based on crown closure, basal area, or volume depending on the province or territory. A total of ten species can be used in one label. The CAS attribute will capture estimation to the nearest percent; however, most inventories across Canada describe species to the nearest 10% (in actual percent value or multiples of 10). Species composition for each forest stand and layer must sum to 100%.  

The detailed table for species composition is presented in Appendix 7. Some inventories (Alberta Phase 3, Saskatchewan UTM, Quebec TIE, and Newfoundland, and National Parks) do not recognize a percentage breakdown of species but rather group species as contributing a major (greater than 26 percent) or minor (less than 26 percent) amount to the composition. Also included in Appendix 7 is a translation table that assigns a species composition percentage breakdown for those inventories that do not have a percentage breakdown.  

CAS species codes are derived from the species' Latin name using the first four letters of the Genus and the first four letters of the Species unless there is a conflict, then the last letter of the species portion of the code is changed. Unique codes are required for generic groups and hybrids. A species list has been developed representing every inventory species identified across Canada including hybrids, exotics and generic groups (Appendix 8). Generic groups represent situations where species were not required to be recognized past the generic name or where photo interpreters could not identify an individual species. A list of species that is represented by the generic groups by province, territory, or Park has also been developed and is presented in Appendix 9.  Error and missing value codes:*  

| species_1 - species_10                                                                                                | values |
| :---------------------------------------------------------------------------------------------------------------------- | :-------------- |
| Species code. Example: Populus tremuloides, Trembling Aspen. Ten species can be listed per layer per polygon. | POPU TREM       |



### species_per

| species_per_1 - species_per_10                                                                                                                                      | values |
| :---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------- |
| Percentage of a species or generic group of species that contributes to the species composition of a polygon. Must add up to 100%. | 1-100          |




### origin

Stand origin is the average initiation year of codominant and dominant trees of the leading species within each layer of a polygon. Origin is determined either to the nearest year or decade. An upper and lower bound is used to identify CAS origin. The detailed stand origin table is presented in Appendix 10. 

| origin_upper, origin_lower           | values |
| :---------------------------------------- | :-------------- |
| Upper Bound - upper bound of an age class | 0 - 2020        |
| Lower Bound - lower bound of an age class | 0 - 2020        |



### site_class  

Site class is an estimate of the potential productivity of land for tree growth. Site class reflects tree growth response to soils, topography, climate, elevation, and moisture availability. See Appendix 11 for the detailed site table.  

| site_class                                                  | values |
| :----------------------------------------------------------- | :-------------- |
| Unproductive - cannot support a commercial forest            | U               |
| Poor - poor tree growth based on age height relationship     | P               |
| Medium - medium tree growth based on age height relationship | M               |
| Good - medium tree growth based on age height relationship   | G               |



### site_index  

Site Index is an estimate of site productivity for tree growth. It is derived for all forested polygons based on leading species, height, and stand age based on a specified reference age. Site index is not available for most inventories across Canada. See Appendix 11 for the detailed site table.  

| site_index                                                                       | values |
| :-------------------------------------------------------------------------------- | :-------------- |
| Estimate of site productivity for tree growth based on a specified reference age. | 0 - 99          |
