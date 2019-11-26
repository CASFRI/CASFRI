## 3.0 CAS Attributes

Updated: 2019-08-09

The CAS base polygon data provides polygon specific information and links the original inventory polygon ID to the CAS ID. Identification attributes include original stand ID, CAS Stand ID, Mapsheet ID, and Identification ID. Polygon attributes include polygon area and polygon perimeter. Inventory Reference Year, Photo Year, and Administrative Unit are additional identifiers.




### cas_id

The attribute cas_id is an alpha-numeric identifier that is unique for each polygon within CAS database.

| cas_id                                             | values |
| :----------------------------------------------------------- | :-------------- |
| CAS stand identification - unique number for each polygon within CAS | alpha numeric           |



### orig_stand_id

Original stand identification - unique number for each polygon within the original inventory.

| orig_stand_id                                             | values |
| :----------------------------------------------------------- | :-------------- |
| Unique number for each polygon within the original inventory | 1 - 10,000,000           |



### stand_structure

Structure is the physical arrangement or vertical pattern of organization of the vegetation within a polygon. A stand can be identified as single layered, multilayered, complex, or horizontal. A single layered stand has stem heights that do not vary significantly and the vegetation has only one main canopy layer.

A multilayered stand can have several distinct layers and each layer is significant, has a distinct height difference, and is evenly distributed. Generally the layers are intermixed and when viewed vertically, one layer is above the other. Layers can be treed or non-treed. Up to 9 layers are allowed; most inventories recognize only one or two layers. The largest number of layers recognized is in the British Columbia VRI with 9 followed by Saskatchewan SFVI with 7 and Manitoba FLI with 5. Each layer is assigned an independent description with the tallest layer described in the upper portion of the label. The number of layers and a ranking of the layers can also be assigned. Some inventories (e.g. Saskatchewan UTM, Quebec TIE, Prince Edward Island, and Nova Scotia) can imply that a second layer exists; however, the second layer is not described or only a species type is indicated.

Complex layered stands exhibit a high variation in tree heights. There is no single definitive forested layer as nearly all height classes (and frequently ages) are represented in the stand. The height is chosen from a stand midpoint usually followed by a height range.

Horizontal structure represents vegetated or non-vegetated land with two or more homogeneous strata located within other distinctly different homogeneous strata within the same polygon but the included strata are too small to map separately based on minimum polygon size rules. This attribute is also used to identify multi- label polygons identified in biophysical inventories such as Wood Buffalo National Park and Prince Albert National Park. The detailed table for stand structure is presented in Appendix 3.

| stand_structure | values |
| :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------- |
| Single layered - vegetation within a polygon where the heights do not vary significantly. | S|
| Multilayered - two or more distinct layers of vegetation occur. Each layer is significant, clearly observable and evenly distributed. Each layer is assigned an independent description. | M|
| Complex - stands exhibit a high variation of heights with no single | C|
| Horizontal - two or more significant strata within the same polygon; at least one of the strata is too small to delineate as a separate polygon. | H |



### num_of_layers  

Number of Layers is an attribute related to stand structure and identifies how many layers have been identified for a particular polygon.  

| num_of_layers                                                | values |
| :----------------------------------------------------------- | :----- |
| Identifies the number of vegetation or non vegetation layers assigned to a particular polygon. A maximum of 9 layers can be identified. | 1 - 9  |



### identification_id

Unique number for a particular inventory section.

| identification_id                                | values   |
| :----------------------------------------------- | :------- |
| Unique number for a particular inventory section | 1 - 1000 |



### map_sheet_id

Map sheet identification according to original naming convention for an inventory.

| map_sheet_id                                                 | values        |
| :----------------------------------------------------------- | :------------ |
| Map sheet identification according to original naming convention for an inventory | alpha numeric |



### casfri_area

The attribute **casfri_area** measures the area of each polygon in hectares (ha). It is calculated by PostgreSQL during the conversion phase. It is measured to 2 decimal places.

| casfri_area                           | values        |
| :------------------------------------ | :------------ |
| Polygon (stand) area in hectares (ha) | 0.01 - 10,000 |



### casfri_perimeter

The attribute **casfri_perimeter** measures the perimeter of each polygon in metres (m). It is calculated by PostgreSQL during the conversion phase. It is measured to 2 decimal places.

| casfri_perimeter                        | values          |
| :-------------------------------------- | :-------------- |
| Polygon (stand) perimeter in metres (m) | 0.01 - infinity |



### src_inv_area

The attribute **src_inv_area** measures the area of each polygon in hectares (ha). It is calculated by the data providers and may contain missing values. It is measured to 2 decimal places.

| src_inv_area                          | values        |
| :------------------------------------ | :------------ |
| Polygon (stand) area in hectares (ha) | 0.01 - 10,000 |



### stand_photo_year

The attribute **stand_photo_year** is a identifies the year in which the aerial photography was conducted for a particular polygon. This is in contrast to photo_year_start and photo_year_end which identify the interval for when the inventory was completed.

| stand_photo_year                                             | values      |
| :----------------------------------------------------------- | :---------- |
| Identifies the year in which the aerial photography was conducted | 1900 - 2020 |

