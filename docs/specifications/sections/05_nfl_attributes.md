## 5.0 NFL Attributes

Updated: 2019-08-08



### cas_id

The attribute cas_id is an alpha-numeric identifier that is unique for each polygon within CAS database.

| cas_id                                                       | values        |
| :----------------------------------------------------------- | :------------ |
| CAS stand identification - unique number for each polygon within CAS | alpha numeric |



### soil_moist_reg  

Soil moisture regime describes the available moisture supply for plant growth over a period of several years. Soil moisture regime is influenced by precipitation, evapotranspiration, topography, insolation, ground water, and soil texture. The CAS soil moisture regime code represents the similarity of classes across Canada. The detailed soil moisture regime table and CAS conversion is presented in Appendix 4.  

| soil_moist_reg                                               | values |
| :----------------------------------------------------------- | :----- |
| Dry - Soil retains moisture for a negligible period following precipitation with very rapid drained substratum. | D      |
| Mesic - Soils retains moisture for moderately short to short periods following precipitation with moderately well drained substratum. | F      |
| Moist - Soil retains abundant to substantial moisture for much of the growing season with slow soil infiltration. | M      |
| Wet - Poorly drained to flooded where the water table is usually at or near the surface, or the land is covered by shallow water. | W      |
| Aquatic - Permanent deep water areas characterized by hydrophytic vegetation (emergent) that grows in or at the surface of water. | A      |
| Blank - no value                                             | NA     |



### structure_per  

The attribute **structure_per** is assigned when a complex or horizontal structured polygon is identified. Stand structure percent is used with horizontal stands and identifies the percentage of stand area, assigned in 10% increments, attributed by each stratum within the entire polygon and must add up to 100%. Any number of horizontal strata can be described per horizontal polygon.

| structure_per                                                | values |
| :----------------------------------------------------------- | :----- |
| Used with horizontal stands to identify the percentage, in 10% increments, strata within the polygon. Must add up to 100%. Only two strata represented by each homogeneous descriptions are allowed per polygon. | 1 - 9  |



### layer  

Layer is an attribute related to stand structure that identifies which layer is being referred to in a multi-layered stand. The layer identification creates a link between each polygon attribute and the corresponding layer. Layer 1 will always be the top (uppermost) layer in the stand sequentially followed by Layer 2 and so on.  

The maximum number of layers recognized is nine. The uppermost layer may also be a veteran (V) layer. A veteran layer refers to a treed layer with a crown closure of 1 to 5 percent and must occur with at least one other layer; it typically includes the oldest trees in a stand.  

| layer                                                        | values   |
| :----------------------------------------------------------- | :------- |
| Identifies the number of vegetation or non vegetation layers assigned to a particular polygon. A maximum of 9 layers can be identified. | 1 - 9, V |



### layer_rank  

Layer Rank value is an attribute related to stand structure and refers to layer importance for forest management planning, operational, or silvicultural purposes. When a Layer Rank is not specified, layers can be sorted in order of importance by layer number.  

| layer_rank                                                   | values |
| :----------------------------------------------------------- | :----- |
| Layer Rank - value assigned sequentially to layer of importance. Rank 1 is the most important layer followed by Rank 2, etc. | 1 - 9  |
| Blank - no value                                             | NA     |



### crown_closure _upper, crown_closure_lower 

Crown closure is an estimate of the percentage of ground area covered by vertically projected tree crowns, shrubs, or herbaceous cover. Crown closure is usually estimated independently for each layer.Crown closure is commonly represented by classes and differs across Canada therefore, CAS recognizes an upper and lower percentage bound for each class. The detailed crown closure table is presented in Appendix 5.  

| crown_closure_upper, crown_closure_lower           | values  |
| :------------------------------------------------- | :------ |
| Upper Bound - upper bound of a crown closure class | 0 - 100 |
| Lower Bound - lower bound of a crown closure class | 0 - 100 |
| Blank - no value                                   | NA      |



### height_upper, height_lower  

Stand height is based on an average height of leading species of dominant and co-dominant heights of the vegetation layer and can represent trees, shrubs, or herbaceous cover. Height can be represented by actual values or by height class and its representation is variable across Canada; therefore, CAS will use upper and lower bounds to represent height. The detailed height table is presented in Appendix 6. 

| height_upper, height_lower                  | values  |
| :------------------------------------------ | :------ |
| Upper Bound - upper bound of a height class | 0 - 100 |
| Lower Bound - lower bound of a height class | 0 - 100 |



### nat_non_veg  

The Naturally Non-Vegetated class refers to land types with no vegetation cover. The maximum vegetation cover varies across Canada but is usually less than six or ten percent. The detailed table, CAS codes, and CAS conversion rule set are presented in Appendix 12.  

| nat_non_veg                                                | values |
| :--------------------------------------------------------- | :----- |
| Alpine - high elevation exposed land                       | AP     |
| Lake - ponds, lakes or reservoirs                          | LA     |
| River - double-lined watercourse                           | RI     |
| Ocean - coastal waters                                     | OC     |
| Rock or Rubble - bed rock or talus or boulder field        | RK     |
| Sand - sand dunes, sand hills, non recent water sediments  | SA     |
| Snow/Ice - ice fields, glaciers, permanent snow            | SI     |
| Slide - recent slumps or slides with exposed earth         | SL     |
| Exposed Land - other non vegetated land                    | EX     |
| Beach - adjacent to water bodies                           | BE     |
| Water Sediments - recent sand and gravel bars              | WS     |
| Flood - recent flooding including beaver ponds             | FL     |
| Island - vegetated or non vegetated                        | IS     |
| Tidal Flats - non vegetated feature associated with oceans | TF     |
| Blank - no value                                           | NA     |



### non-veg_anth 

Non-vegetated anthropogenic areas are influenced or created by humans. These sites may or may not be vegetated. The detailed table, CAS codes, and CAS conversion rule set are presented in Appendix 12.  

| non_veg_anth                                                 | values |
| :----------------------------------------------------------- | :----- |
| Industrial - industrial sites                                | IN     |
| Facility/Infrastructure - transportation, transmission, pipeline | FA     |
| Cultivated - pasture, crops, orchards, plantations           | CL     |
| Settlement - cities, towns, ribbon development               | SE     |
| Lagoon - water filled, includes treatment sites              | LG     |
| Borrow Pit - associated with facility/infrastructure         | BP     |
| Other - any not listed                                       | OT     |
| Blank - no value                                             | NA     |



### non_for_veg  

Non-forested vegetated areas include all natural lands that have vegetation cover with usually less than 10% tree cover. These cover types can be stand alone or used in multi-layer situations. The detailed table, CAS codes, and CAS conversion rule set are presented in Appendix 12.    

| non_for_veg                                          | values |
| :--------------------------------------------------- | :----- |
| Tall Shrub - shrub lands with shrubs > 2 meters tall | ST     |
| Low Shrub - shrub lands with shrubs < 2 meters tall  | SL     |
| Forbs - herbaceous plants other than graminoids      | HF     |
| Herbs - no distinction between forbs and graminoids  | HE     |
| Graminoids - grasses, sedges, rushes, and reeds      | HG     |
| Bryoid - mosses and lichens                          | BR     |
| Open Muskeg - wetlands less than 10% tree cover      | OM     |
| Tundra - flat treeless plains                        | TN     |
| Blank - no value                                     | NA     |

