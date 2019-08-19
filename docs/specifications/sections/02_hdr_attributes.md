## 2.0 HDR Attributes 

Updated: 2019-08-09

Header information is a primary element of CAS. Header information identifies the source data set including jurisdiction, ownership, tenure type, inventory type, inventory version, inventory start and finish date and the year of acquisition for CAS. These attributes are described below.



### inventory_id

The attribute **inventory_id** is a unique identifier that is assigned to each forest inventory. It is the concatenation of the **jurisdiction** attribute plus an integer that increments with newer inventories within a jurisdiction.

| inventory_id | values |
| :-------------------------- | :-------------- |
| jurisdiction plus 2 digits | e.g., BC08, AB06, AB16, NB01 |



### jurisdiction  

The attribute **jurisdiction** identifies the province, territory or national park from which the inventory data came.

| jurisdiction | values |
| :-------------------------- | :-------------- |
| British Columbia | BC |
| Alberta | AB |
| Saskatchewan | SK |
| Manitoba| MB |
| Ontario | ON |
| Quebec | QC |
| Prince Edward Island | PE |
| New Brunswick| NB |
| Nova Scotia | NS |
| Newfoundland and Labrador | NL |
| Yukon Territory | YK |
| Northwest Territories | NT |
| Wood Buffalo National Park | WB |
| Prince Albert National Park | PA |



### owner_type

The attribute **owner_type** identifies who owns the inventory data. Ownership of the inventory can be federal, provincial, territory, industry, private, or First Nation.

| owner_type | values |
| :-------------------------- | :-------------- |
| Provincial Government | PROV_GOV |
| Federal Government | FED_GOV |
| Yukon Territory or Northwest Territories | TERRITORY |
| First Nations | FN |
| Industry | INDUSTRY |
| Private | PRIVATE |



### owner_name

The attribute **owner_name** identifies who owns the land that the inventory covers, and degree of permission to which the data can be used. Ownership of the land is identified as being crown, private, military, or First Nation.

| owner_name | values   |
| :-------------------------- | :-------------- |
| Crown | CROWN |
| Private | PRIVATE |
| Military | MILITARY |
| First Nation | FN |



### standard_type

The attribute **standard_type** identifies the kind of inventory that was produced for an area. The name, abbreviation, or acronym usually becomes the name used to identify an inventory. For example, Alberta had a series of successive forest inventories called Phase 1, Phase 2, and Phase 3. As inventories became more inclusive of attributes other than just the trees, they became known as vegetation inventories, for example, the Alberta Vegetation Inventory or AVI. The inventory type along with a version number usually identifies an inventory.

| standard_type | values        |
| :-------------------------- | :-------------- |
| Inventory name or type of inventory | Alpha numeric    |



### standard_version

The attribute **standard_version** identifies the standards used to produce a consistent inventory, usually across large land bases and for a relatively long period of time. The inventory type along with a version number usually identifies an inventory.

| standard_version | values        |
| :-------------------------- | :-------------- |
| The standard and version of the standard used to create the inventory | Alpha numeric |



### standard_id

The attribute **standard_id** identifies...

| standard_id                                                  | values        |
| :----------------------------------------------------------- | :------------ |
| The standard and version of the standard used to create the inventory | Alpha numeric |



### standard_revision

The attribute **standard_revision** identifies...

| standard_revision                                            | values        |
| :----------------------------------------------------------- | :------------ |
| The standard and version of the standard used to create the inventory | Alpha numeric |



### inventory_manual

The attribute **inventory_manual** identifies the documentation associated with the inventory data e.g., metadata, data dictionary, manual, etc.

| inventory_manual | values |
| :-------------------------- | :-------------- |
| Documentation associated with the inventory data | Text   |



### src_data_format

The attribute **src_data_format** identifies the format of the inventory data e.g., geodatabase, shapefile, e00 file.

| src_data_format | values      |
| :-------------------------- | :-------------- |
| ESRI file geodatabase     | Geodatabase |
| ESRI shapefile            | Shapefile   |
| ESRI e00 transfer file    | e00         |
| Microsoft Access database | mdb         |



### acquisition_date

The attribute **acquisition_date** identifies the date at which the inventory data was acquired.

| acquisition_date | values |
| :-------------------------- | :-------------- |
| Date at which the inventory data was acquired | Date   |



### data_transfer

The attribute **data_transfer** identifies the procedure with which the inventory data was acquired. Examples include direct download, ftp transfer, on DVD, etc.

| data_transfer | values |
| :-------------------------- | :-------------- |
| Procedure with which the inventory data was acquired | Text |



### received_from

The attribute **received_from** identifies the person, entity, or website from which the inventory data was obtained.

| received_from | values |
| :-------------------------- | :-------------- |
| Person, entity, or website from which the data was obtained | Text   |



### contact_info

The attribute **contact_info** identifies the contact information (name, address, phone, email, etc.) associated with the inventory data.

| contact_info | values |
| :-------------------------- | :-------------- |
| Contact information associated with the inventory data | text   |



### data_availability

The attribute **data_availability** identifies the type of access to the inventory data e.g., direct contact or open access.

| data_availability | values |
| :-------------------------- | :-------------- |
| Type of access to the inventory data | Text   |



### redistribution

The attribute **redistribution** identifies the conditions under which the inventory data can be redistributed to other parties.

| redistribution | values |
| :-------------------------- | :-------------- |
| Conditions under which the inventory data can be redistributed | Text   |



### permission

The attribute **permission** identifies the degree of permission to which the data can be used i.e., whether the use of the data is unrestricted, restricted or limited..

| permission | permitted values |
| :-------------------------- | :-------------- |
| Use of the inventory data is unrestricted | UNRESTRICTED |
| Use of the inventory data has restrictions | RESTRICTED |
| Use of the data has limitations | LIMITED |



### license_agreement

The attribute **license_agreement** identifies the type of license associated with the inventory data.

| license_agreement | values |
| :-------------------------- | :-------------- |
| Type of license associated with the inventory data | Text |



### photo_year_src

The attribute **photo_year_src** identifies the source data type that is used to define the photo year i.e., the year in which the inventory was considered initiated and completed.

| photo_year_src | values |
| :-------------------------- | :-------------- |
| Source data type that is used to define the photo year | Text |



### photo_year_start

The attribute **photo_year_start** identifies the year in which the inventory was considered initiated. An inventory can take several years to complete; therefore, start and end dates are included to identify the interval for when the inventory was completed.

| photo_year_start | values |
| :-------------------------- | :-------------- |
| Earliest year of aerial photo acquisition | 1900 - 2020 |



### photo_year_end

The attribute **photo_year_end** identifies the year in which the inventory was considered completed. An inventory can take several years to complete; therefore, start and end dates are included to identify the interval for when the inventory was completed. 

| photo_year_end | values |
| :-------------------------- | :-------------- |
| Latest year of aerial photo acquisition | 1900 - 2020 |
