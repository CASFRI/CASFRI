Translation and lookup tables to be used by the translation engine. The tables are organized by inventories and named using a combination of inventory # and standard #, for example for bc_0008 the translation tables would include:

  * bc08_vri01_hdr.csv - rules for translating HDR attributes
  * bc08_vri01_cas.csv - rules for translating CAS attributes
  * bc08_vri01_lyr.csv - rules for translating LYR attributes
  * bc08_vri01_nfl.csv - rules for translating NFL attributes
  * bc08_vri01_dst.csv - rules for translating DST attributes
  * bc08_vri01_eco.csv - rules for translating ECO attributes
  
Each inventory also has lookup tables located in the tables/lookup folder. They are also named using a combination of inventory # and standard #, for example for ab_0006 the tables would include:

  * ab_avi01_crown_closure.csv - crown closure lookup tables  
  * ab_avi01_height.csv - stand height lookup tables  
  * ab_avi01_species.csv - tree species lookup tables  
