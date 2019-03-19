---
title: ""
output:
  html_document:
    toc: true
    toc_float: true
    css: style.css
    keep_md: yes
---

# Inventories

## Alberta

### AB06

### AB16


## British Columbia

### BC08


General

  * All inventory standards appear to be incorporated into latest file geodatabase
  * TFL 48 is not included except for a few polygons (recent disturbances?)

Crown Closure
  
  * The crown_closure field is an integer ranging from 1-100
  * The crown_closure_class_cd field is an integer ranging from 0-10
  * It appears that some values are true integers ranging from 1-100 while others have been converted from classes probably due to different inventory types
  * The perl code however seems to assume that it is translating from 0-10 to 1-100
  * CROWN_CLOSURE_UPPER and CROWN_CLOSURE_LOWER should be the same value in CAS v4 but this is not the case

Height

  * The proj_height_1 field is a float ranging from 0.1 up
  * The proj_height_class_cd_1 field is an integer ranging from 1-8
  * The proj_height_1 field appears to be a mix of true values and values converted from classes

## New Brunswick

### NB01

