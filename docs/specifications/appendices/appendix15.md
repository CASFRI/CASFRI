**Appendix 15**

**PROCEDURES FOR CAS WETLAND DERIVATION**

**(Last Revision September 14, 2010)**

**Introduction**

The Boreal Avian Habitat Modeling project has produced a common
attribute structure (CAS) to accommodate the various forest inventories
across Canada. One attribute of interest is wetland; however, wetland is
not identified for many forest inventories or not complete in others.
This document identifies a means to derive a four-character CAS wetland
code using existing forest attributes for each province or territory. A
complete four- character identification or derivation of wetland is not
always possible depending on the type of attributes recorded. Only a
single generic (W) wetland code is possible to derive for some
inventories and a complete four-character CAS wetland code may not be
possible to derive for other inventories (usually two-character).

The classification scheme used for CAS follows the classes developed by
the National Wetlands Working Group ^5^ and modified by Vitt/Halsey^6^.
The scheme was further modified to take into account coastal wetlands
and alkaline or saline habitats. This model identifies five major
wetland classes based on wetland development from hydrologic, chemical,
and biotic gradients that commonly have strong cross-correlations. Two
of the classes: fen and bog are peat forming with greater than 40 cm of
accumulated organics. The non-peat forming wetlands are subdivided as
shallow open water, marsh (fresh and salt water), and swamp. The CAS
wetland classes and codes are identified in Appendix 1 of the wetland
document.

**British Columbia Forest Cover Inventory**

The Forest Cover Inventory does not lend itself to a very complete
derivation of wetland because there is no moisture regime or other
related classes to key on. A few non productive forest and non forest
categories can be identified. The only source that would provide a more
complete picture of wetland would be via the biogeoclimatic
classification.

The inventory has been or is being converted to VRI. If this conversion
has been done then follow the VRI instructions.

5.  National Wetlands Working Group 1988. Wetlands of Canada. Ecological
    Land Classification Series No. 24.

6.  Alberta Wetland Inventory Standards. Version 1.0. June 1977. L.
    Halsey and D. Vitt.

If species 1 = Sb or Lt and species 1 % = 100 and CC [\>]{.underline}50%
and height [\>]{.underline}12m If species 1 = Sb or Lt and species 2 =
Lt or Sb and CC [\>]{.underline}50% and height [\>]{.underline}12m If
species 1 = Ep or Ea or Cw or Yc or Pl

If species 1 = Sb or Lt and species 2 = Lt or Sb and CC \<50%

If species 1 = Lt and species 1 percent = 100 and CC = any and height \<
12m

> **1.0 Non Productive Forest**

Key on NP designation associated with a forest description where Species
1 = Sb or Cw or Yc.

NP Lowland Forest NP Swamp

Stnn

Stnn

Although lowland and swamp forests are identified as separate categories
in the manual, there is no differentiation identified in the attribute
fields; therefore an NP forest can range from rocky to wetland. Treed
bogs cannot be differentiated from treed swamps. Pine (Pl) swamps can be
identified if they are Species 1 or 2 and have Sb as Species 1 or 2 or
Cw or Yc as Species 2.

**2.0 Non Forest**

Key on non forest attributes.

NP Br can include upland and wetland; therefore, it is only reliable
regionally (Stnn).

Swamp (Symbol) Sons

Muskeg (Symbol) Stnn

**3.0 Ecosite**

Derivation of wetland from a biogeoclimatic ecosite classification is
possible via the PEM (Predictive Ecosite Mapping) or TEM (Terrain)
mapping programs; however it is beyond the scope of this project.

**British Columbia Vegetation Resource Inventory (VRI)**

A general wetland class can be assigned as outlined in Section 1.0
below. A more detailed wetland can be derived as per Section 2.0 and
3.0.

**1.0 General Wetland (W)**

The general wetland code identifies a broad wetland category with no
distinction between wetland classes. Key on Landscape Position W
(Wetland). Assign CAS wetland code „W‟.

**2.0 Treed Polygons**

Key on soil moisture regime 7 and 8, species composition, crown closure,
and height:

If species 1 = Sb and species 1 percent = 100 and crown closure (CC),
50% and height, 12m Btnn

> Stnn
>
> Stnn
>
> Stnn
>
> Ftnn
>
> Ftnn

![](media/image1.jpeg){width="1.4in" height="0.3770833333333333in"}

**3.0 Vegetated Non-treed**

Key on moisture regime 7 and 8 and land cover components for vegetated
and non vegetated categories:

+----+---------------------+--------+--+--+
| ST | > Shrub Tall (\>2m) | > Sons |  |  |
+====+=====================+========+==+==+
|    |                     |        |  |  |
+----+---------------------+--------+--+--+
| SL | > Shrub Low (\<2m)  | > Sons |  |  |
+----+---------------------+--------+--+--+
| HE | > Herb              | > Mong |  |  |
+----+---------------------+--------+--+--+
| HF | > Herb Forb         | > Mong |  |  |
+----+---------------------+--------+--+--+
| HG | > Herb Graminoid    | > Mong |  |  |
+----+---------------------+--------+--+--+
| BY | > Bryoid            | > Fonn |  |  |
+----+---------------------+--------+--+--+
| BM | > Bryoid Moss       | > Fonn |  |  |
+----+---------------------+--------+--+--+
| BL | > Bryoid Lichen     | > Bonn |  |  |
+----+---------------------+--------+--+--+
| MU | > Mudflat           | > Tmnn |  |  |
+----+---------------------+--------+--+--+

**4.0 Ecosite**

Derivation of wetland from a biogeoclimatic ecosite classification is
possible via the PEM (Predictive Ecosite Mapping) or TEM (Terrain)
mapping programs; however it is beyond the scope of this project.

**Alberta Phase 3**

Wetland classes must be derived from several fields because moisture
regime does not exist. Focus must rely on non productive forest land and
non-forest land. It is not possible to differentiate between fens, bogs,
or marshes. Productive Sb and Lt polygons can also be wetland types but
are not possible to differentiate.

**1.0 Open muskeg, Bog, or Marsh**

+--------------+----------------------------------+--------+
| File name S1 | > = OM (Open Muskeg), then =     | > Wo   |
+==============+==================================+========+
| File name S1 | > = TM (Treed Muskeg), then =    | > Wt   |
+--------------+----------------------------------+--------+
| File name S1 | > = DS (Deciduous shrub), then = | > Sons |
+--------------+----------------------------------+--------+
| File name S1 | > = FL (Flooded Land), then =    | > Mong |
+--------------+----------------------------------+--------+

Note: DS could include some upland areas in foothill, mountain, and
shield areas.

**2.0 Forest Land**

Need to include Sb and Lt stands that are classified as productive land.
Suggest key on species Sb and Lt, and commercialism U (low
uncommercial). This will include transitional stands that are probably
moist upland types. It may include upland Sb types in foothill,
mountain, and shield areas.

File name S1 = Sb or Lt or Bw and it is 100% and commercialism = U, then
= Stnn

> File name S1 = Sb or Lt or Bw and S2 = Lt, Sb, or Bw and commercialism
> = U Stnn
>
> **Alberta Vegetation Inventory (AVI)**
>
> Includes all versions of AVI 2.1, 2.1+ (enhanced), and 2.2
> inventories. The soil moisture regime, tree species, non-forested, and
> crown closure fields will be required to derive wetlands. Wet
> anthropogenic cultivated (e.g. CA, CP and CPR) and seeded industrial
> (e.g. CIP and CIW) are not considered. Patterning in fens and
> permafrost features cannot be derived from AVI data. Multi-layered
> (stand structure = M) polygons will require a query of both layers to
> identify wetland classes. Some of the enhanced versions of AVI may
> contain an Alberta Wetland Inventory field.
>
> **1.0 Alberta Wetland Inventory**
>
> The CAS wetland coding is based on the Alberta Wetland Inventory;
> therefore, if this field is available then it will translate directly
> into CAS wetland.

+-----------------+-----------------+-----------------+-----------------+
| **2.0           |                 |                 |                 |
| Non-Forested    |                 |                 |                 |
| Land**          |                 |                 |                 |
+=================+=================+=================+=================+
| Key on soil     |                 |                 |                 |
| moisture regime |                 |                 |                 |
| (SMR) = W       |                 |                 |                 |
| (wet):          |                 |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| If Non-forested | > Sons          |                 |                 |
| = SO or SC, and |                 |                 |                 |
| crown closure   |                 |                 |                 |
| \> 3 (30%),     |                 |                 |                 |
| then =          |                 |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
|                 |                 |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| If Non-forested | > Mong          |                 |                 |
| = HG and/or SC  |                 |                 |                 |
| or SO and crown |                 |                 |                 |
| closure is \<   |                 |                 |                 |
| 3, then =       |                 |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| If Non-forested | > Mong          |                 |                 |
| = HF, then =    |                 |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| If Non-forested | > Fong          |                 |                 |
| = BR, then =    |                 |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| If Naturally    | > Sons          |                 |                 |
| non-vegetated = |                 |                 |                 |
| NMB             |                 |                 |                 |
+-----------------+-----------------+-----------------+-----------------+

> Note: For multi- layered polygons (stand structure = M) with shrub
> over topping HG, HF, or BR, then polygon is a Sons if shrub layer has
> crown closure of [\>]{.underline} 3 (30%), otherwise will be Mong or
> Fong as indicated above.
>
> **3.0 Forest Land**
>
> Key on soil moisture regime (SMR) = W (wet)
>
> If Forested and crown closure = A or B and Species 1 or 2 = Lt, then
> Ft
>
> If Forested and crown closure = C and Species 1 or 2 = Lt, then Stnn
>
> If Forested and crown closure = D and Species 1 or 2 = Lt, then Sfnn
>
> If Forested and crown closure = A or B and Species 1 = Sb and Species
> 1 % =100, then Btnn

+-----------------+-----------------+-----------------+-----------------+
| > If Forested   | > Stnn          |                 |                 |
| > and crown     |                 |                 |                 |
| > closure = C   |                 |                 |                 |
| > and Species 1 |                 |                 |                 |
| > = Sb and      |                 |                 |                 |
| > Species 1 %   |                 |                 |                 |
| > =100, then    |                 |                 |                 |
+=================+=================+=================+=================+
| > If Forested   | > = Sb and      | > Sfnn          |                 |
| > and crown     | > Species 1 %   |                 |                 |
| > closure = D   | > =100, then    |                 |                 |
| > and Species 1 |                 |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| > If Forested   | > Stnn          |                 |                 |
| > and crown     |                 |                 |                 |
| > closure = A,  |                 |                 |                 |
| > B, or C and   |                 |                 |                 |
| > Spp 1 = Sb or |                 |                 |                 |
| > Fb and Spp 2  |                 |                 |                 |
| > not = to Lt   |                 |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| > If Forested   | > Sfnn          |                 |                 |
| > and crown     |                 |                 |                 |
| > closure = D   |                 |                 |                 |
| > and Spp 1 =   |                 |                 |                 |
| > Sb or Fb and  |                 |                 |                 |
| > Spp 2 not =   |                 |                 |                 |
| > to Lt         |                 |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| > If Forested   | > Stnn          |                 |                 |
| > and crown     |                 |                 |                 |
| > closure = A,  |                 |                 |                 |
| > B, or C and   |                 |                 |                 |
| > Species 1 =   |                 |                 |                 |
| > Sw, then      |                 |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| > If Forested   | > = Sw, then    | > Sfnn          |                 |
| > and crown     |                 |                 |                 |
| > closure = D   |                 |                 |                 |
| > and Species 1 |                 |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| > If Forested   | > Stnn          |                 |                 |
| > and crown     |                 |                 |                 |
| > closure = A,  |                 |                 |                 |
| > B, or C and   |                 |                 |                 |
| > Species 1 =   |                 |                 |                 |
| > Bw or Pb,     |                 |                 |                 |
| > then          |                 |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| > If Forested   | > = Bw or Pb,   | > Sfnn          |                 |
| > and crown     | > then          |                 |                 |
| > closure = D   |                 |                 |                 |
| > and Species 1 |                 |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
|                 |                 |                 |                 |
+-----------------+-----------------+-----------------+-----------------+

> Note: For multi-layered polygons (stand structure = M) with two tree
> layers, a query of both layers will be required to derive wetland
> classes.
>
> **Saskatchewan UTM Inventory**
>
> The UTM inventory does not have a moisture regime field; therefore
> wetland must be derived from several attributes including drainage
> class, species, height class, crown closure class, and non productive
> lands. Non productive polygons are identified with symbols.
>
> **1.0 Productive Forest Land**
>
> If Drainage Code = PVP and or soil texture = O (Organic); or If
> Drainage Code = PD and texture = O, then:

+-----------------------+-----------------------+-----------------------+
| If species 1          | > = bS and bS = 100%, | > Stnn                |
|                       | > and crown closure = |                       |
|                       | > C or D, then        |                       |
+=======================+=======================+=======================+
| If species 1          | > = bS and bS = 100%, | > Btnn                |
|                       | > and crown closure   |                       |
|                       | > =A or B, then       |                       |
+-----------------------+-----------------------+-----------------------+
| If species 1          | > = bS or tL or wB or | > Stnn                |
|                       | > mM and species 2 =  |                       |
|                       | > tL or bS or wB or   |                       |
|                       | > mM, then            |                       |
+-----------------------+-----------------------+-----------------------+

> Note: some Stnn polygons will be fens or bogs and some Btnn polygons
> will be fens.
>
> **2.0 Non Productive Lands**
>
> Drainage and texture codes are not applied to non productive lands.

+-----------+----------------+--------+
| Code 3100 | > Treed Muskeg | > Wt   |
+===========+================+========+
| Code 3300 | > Clear Muskeg | > Wo   |
+-----------+----------------+--------+
| Code 3500 | > Brushland    | > Sons |
+-----------+----------------+--------+
| Code 3600 | > Meadow       | > Mong |
+-----------+----------------+--------+
| Code 5100 | > Flooded      | > Mong |
+-----------+----------------+--------+

> Note: some meadow and Brushland could be upland moist and very moist
> sites.
>
> **Saskatchewan SFVI**
>
> SFVI is very similar to AVI with key attributes being soil moisture
> regime, species, crown closure, height, and non forest land.
> Patterning in fens and permafrost features cannot be derived from SFVI
> data. Multi-layered polygons will require a query of all layers to
> identify wetland classes.
>
> **1.0 Forested Land**
>
> Moisture class code = MW (moderately wet):

+-------------+-------------+-------------+-------------+-------------+
| > If        | > = bS and  | > Btnn      |             |             |
| > species 1 | > species 1 |             |             |             |
|             | > % =100,   |             |             |             |
|             | > and crown |             |             |             |
|             | > closure   |             |             |             |
|             | > \<50%,    |             |             |             |
|             | > and       |             |             |             |
|             | > height    |             |             |             |
|             | > \<12m     |             |             |             |
+=============+=============+=============+=============+=============+
| > If        | > = any and |             |             | > Stnn      |
| > species 1 | > crown     |             |             |             |
|             | > closure   |             |             |             |
|             | > \>50%     |             |             |             |
+-------------+-------------+-------------+-------------+-------------+
|             |             |             |             |             |
+-------------+-------------+-------------+-------------+-------------+

<table>
<thead>
<tr class="header">
<th>If species 1 = bS and species 1 % =100, and crown closure &lt;50%, and height &gt;12m</th>
<th><blockquote>
<p>Stnn</p>
</blockquote></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>If species 1 = any and crown closure &gt; 70%</td>
<td></td>
<td></td>
<td></td>
<td><blockquote>
<p>Sfnn</p>
</blockquote></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>Moisture class code = W (wet):</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>If species 1 = bS and species 1 % =100, and crown closure &lt;50%, and height &lt;12m</td>
<td><blockquote>
<p>Btnn</p>
</blockquote></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>If species 1 = bS and species 1 % =100, and crown closure &lt;50%, and height &gt;12m</td>
<td><blockquote>
<p>Stnn</p>
</blockquote></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>If species 1 = bS and species 1 % =100, and CC &gt;50% and &lt;70%, and height &gt;12m</td>
<td><blockquote>
<p>Stnn</p>
</blockquote></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>If species 1 = bS and species 1 % =100, and CC &gt;70%, and height &gt;12m</td>
<td></td>
<td></td>
<td><blockquote>
<p>Sfnn</p>
</blockquote></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>Moisture class code = W or VW (very wet):</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>If species 1 = bS or tL or wB or bP or mM and species 2 = tL or bS or wB or bP or mM</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>And crown closure &gt;50% and &lt;70% and height &gt;12m</td>
<td><blockquote>
<p>Stnn</p>
</blockquote></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>If species 1 = bS or tL or wB or bP or mM and species 2 = tL or bS or wB or bP or mM</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>and crown closure &gt; 70%</td>
<td><blockquote>
<p>Sfnn</p>
</blockquote></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>If species 1 = bS or tL and species 2 = bS or tL and CC &lt; 50% and height &lt; 12m</td>
<td><blockquote>
<p>Ftnn</p>
</blockquote></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>If species 1 = tL and species 1 % =100, and CC &gt;50% and &lt;70%, and height &gt;12m</td>
<td><blockquote>
<p>Stnn</p>
</blockquote></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>If species 1</td>
<td><blockquote>
<p>= tL and species 1 % =100, and CC &gt;70%</p>
</blockquote></td>
<td></td>
<td></td>
<td><blockquote>
<p>Sfnn</p>
</blockquote></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>If species 1</td>
<td><blockquote>
<p>= tL and species 1 % =100, and CC &lt;50% and height = any</p>
</blockquote></td>
<td><blockquote>
<p>Ftnn</p>
</blockquote></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>If species 1</td>
<td><blockquote>
<p>= wB or mM or gA or wE and species 1 % = 100 and CC &lt; 70%</p>
</blockquote></td>
<td><blockquote>
<p>Stnn</p>
</blockquote></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>If species 1</td>
<td><blockquote>
<p>= wB or mM or gA or wE and species 1 % = 100 and CC &gt; 70%</p>
</blockquote></td>
<td><blockquote>
<p>Sfnn</p>
</blockquote></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
</tbody>
</table>

Note: For multi-layered polygons with more than one tree layer, a query
of all layers will be required to derive wetland classes.

**2.0 Non Forest Land**

If moisture class code = MW or W or VW: and non forested = HE or GR,
then and non forested = MO, then and non forested = Av, then

Mong

Fonn

Oonn

and TS (includes all TS shrub species) or LS (includes all LS shrub
species) and Sons crown closure is \> 25%.

Note: For multi-layered polygons with shrub over topping GR, HE, or MO,
then polygon is a Sons if shrub layer has crown closure of \> 25%,
otherwise will be Mong or Fong as indicated above.

**3.0 Ecosite**

Ecosite is relatively new; the following codes are in draft form. Note
that there is no ecosite identified for shrubby swamp for all three
ecoregions or marshes for Taiga Shield and Boreal Shield.

Taiga Shield Boreal Shield Boreal Plain

![](media/image2.jpeg){width="6.541666666666667in"
height="2.013888888888889e-2in"}

+-------+-------------+-------------+--------+
| TS 12 | > BS 20     | > BP 20     | > Bonn |
+=======+=============+=============+========+
| TS 11 | > BS 19     | > BP 19     | > Bong |
+-------+-------------+-------------+--------+
| TS 10 | > BS 18     | > BP 18     | > Bons |
+-------+-------------+-------------+--------+
| TS 9  | > BS 17     | > BP 17     | > Btnn |
+-------+-------------+-------------+--------+
| TS 13 | > BS 23, 22 | > BP 21     | > Ftnn |
+-------+-------------+-------------+--------+
| TS 14 | > BS 23, 22 | > BP 23, 22 | > Fons |
+-------+-------------+-------------+--------+
| TS 15 | > BS 24     | > BP 24     | > Fong |
+-------+-------------+-------------+--------+
| TS 16 | > BS 25     | > BP 25     | > Fonn |
+-------+-------------+-------------+--------+
| TS 8  | > BS 16     | > BP 16     | > Stnn |
+-------+-------------+-------------+--------+
| TS NA | > BS NA     | > BP NA     | > Sons |
+-------+-------------+-------------+--------+
| TS NA | > BS NA     | > BP 26     | > Mong |
+-------+-------------+-------------+--------+

> **Manitoba Prior to 1998**
>
> For FRI 1.0, 1.1 and 1.2, a good estimation of wetland, both treed and
> non-treed, can be derived from the productive forest land, non
> productive forest, and non forested land codes. Taiga and tundra
> cannot identify wetland areas. A moisture code and landform code were
> added for FRI 1.3 (1996-1997). Key on the same attributes as described
> for FRI 1.0, 1.1. or 1.2 or key on moisture code 4 (wet) to derive a
> generic wetland. Landform code 8 (depressions, poorly drained) can
> also be used to derive a generic wetland.
>
> **1.0 Non Productive**
>
> Key on non productive forested land and non forested land:
>
> Black spruce treed muskeg (701) = Btnn, Tamarack larch treed muskeg
> (702) = Ftnn, Eastern cedar treed muskeg (703) = Stnn, Willow (721) =
> Sons, Alder (722) = Sons, Dwarf birch (723) = Sons,
>
> Shrub (724) = Sons,
>
> Wet meadow (823) = Mong
>
> Taiga (704) and Barrens-Tundra (801) will contain wetland; however it
> cannot be separated from upland.
>
> **2.0 Productive**
>
> Key on species cover type and sub type.

+----------------+--------------------------+--------+
| > Tamarack     | > 30, 31, 32, 70, 71, 72 | > Stnn |
+================+==========================+========+
| > Cedar        | > 36, 37, 76, 77         | > Stnn |
+----------------+--------------------------+--------+
| > Black spruce | > 16, 17, 56, 57         | > Stnn |
+----------------+--------------------------+--------+
| > Willow       | > 9E                     | > Sons |
+----------------+--------------------------+--------+
|                |                          |        |
+----------------+--------------------------+--------+

> Pure black spruce cover type 13 can be wetland (Stnn). The only way to
> identify which stands are wetlands is if ecosite is identified. The
> ecosite codes that represent Stnn will be V30, V31, V32, and V33. Some
> black ash sites will be Stnn, particularly if dominant to black ash.
>
> **3.0 Ecosite**
>
> Ecosite (vegetation type) is available for forested areas only. If
> this attribute is provided, then key on this attribute for forested
> areas as an alternative to 2.0 above or use ecosite as an enhancement
> using other available attributes as well.

+-----+------------------------------------------------------------+--------+
| V2  | > Black ash (White elm) hardwood (if have local knowledge) | > Stnn |
+=====+============================================================+========+
| V19 | > Cedar conifer and mixedwood                              | > Stnn |
+-----+------------------------------------------------------------+--------+
| V20 | > Tamarack/Labrador tea                                    | > Stnn |
+-----+------------------------------------------------------------+--------+
| V30 | > Black spruce/Labrador tea/Feather moss (Sphagnum)        | > Stnn |
+-----+------------------------------------------------------------+--------+
| V31 | > Black spruce/Herb rich/Sphagnum (Feather moss)           | > Stnn |
+-----+------------------------------------------------------------+--------+
| V32 | > Black spruce/Herb poor/Sphagnum (Feather moss)           | > Ftnn |
+-----+------------------------------------------------------------+--------+
| V33 | > Black spruce/Sphagnum                                    | > Btnn |
+-----+------------------------------------------------------------+--------+

> Note: V20 can also be Ftnn (treed fens).
>
> A soils type is also coded for FRI 1.2. Key on soil types for deep
> organic; S12F (feather moss) and S12S (Sphagnum) to identify locations
> of generic wetlands.
>
> **Manitoba Forest Land Inventory (FLI)**
>
> A wetland classification is included in FLI; however, it only
> identifies non-treed wetlands. There are some options for deriving
> treed wetlands. One is to key on ecosite and the other is to key on
> the regular forest attributes. Both options are provided below. A
> general wetland assignment (W) is also possible.
>
> **1.0 General Wetland (W)**
>
> Key on soil landscape model (LANDMOD) code O (organic) and W (wet
> channel sloughs). Assign these polygons with CAS code „W‟. This will
> identify most wetlands (treed and non-treed) at a general level.
>
> **2.0 Non-Treed Wetland**
>
> Non-treed wetlands are identified in FLI. They are identified with the
> field WETECO1 and WETECO2. WETECO1 is the predominant wetland type and
> is the field that should be used to derive the CAS wetland. To derive
> CAS wetland codes from non-treed FLI wetland codes do the following:

+-------+----------------------------+--------+
| > WE1 | > Open bog-lowland shrub = | > Bons |
+=======+============================+========+
| > WE2 | > Open poor fen-lowland =  | > Fons |
+-------+----------------------------+--------+
|       |                            |        |
+-------+----------------------------+--------+

> WE3 Open rich fen =
>
> We4 Thicket swamp =
>
> WE5 Shore fen =
>
> WE6 Meadow marsh =
>
> WE7 Exposed marsh =
>
> WE8 Exposed marsh =
>
> WE9 Open water marsh =
>
> WE10 Open water marsh =

Fong

Sons

Fons

Mong

Mong

Mong

Mong

Mong

> **3.0 Treed Wetland Using Ecosite**
>
> Treed wetland ecosite codes and descriptions are found in *Forest
> Ecosystem Classification for* *Manitoba.* If they are provided in the
> ecosite field, then to derive treed CAS wetland codes see below:

+-----+-----------------------------------------------------------+--------+
| V2  | > Black ash (White Elm) hardwood =                        | > Stnn |
+=====+===========================================================+========+
| V19 | > Cedar conifer and mixedwood =                           | > Stnn |
+-----+-----------------------------------------------------------+--------+
| V20 | > Tamarack/Labrador tea =                                 | > Ftnn |
+-----+-----------------------------------------------------------+--------+
| V30 | > Black spruce/Labrador tea/feather moss (Sphagnum) =Stnn |        |
+-----+-----------------------------------------------------------+--------+
| V31 | > Black spruce/Herb-rich/Sphagnum (feather moss) =        | > Stnn |
+-----+-----------------------------------------------------------+--------+
| V32 | > Black spruce/Herb-poor/Sphagnum (feather moss) =        | > Ftnn |
+-----+-----------------------------------------------------------+--------+
| V33 | > Black spruce/Sphagnum =                                 | > Btnn |
+-----+-----------------------------------------------------------+--------+

> **4.0 Wetland Derivation Using FLI Polygon Attributes When Ecosite or
> Wetland Fields Are Empty**
>
> **4.1 Treed Wetlands**
>
> If ecosite is not available or a more detailed derivation of forested
> wetland codes is preferred then key on the FLI forested attributes. To
> keep the wetland derivation simple, only refer to Layer 1 except when
> Layer 1 is a veteran layer (CANLAY with code V), then use Layer 2 (SEQ
> 2) instead to derive the wetland class.
>
> First step is to key on moisture regime (MR) code W (wet). This will
> identify all wetland areas. Then key on species composition (SP1, SP2
> and SP1PER, etc) for likely wetland tree species such as black spruce
> and tamarack:

+------------------------------------------------------+--------+--+--+--+--+
| > If SP1 = BS and SP1PER = 100                       | > Btnn |  |  |  |  |
+======================================================+========+==+==+==+==+
| > And CC (crown closure) \<50% and HT (height) \<12m |        |  |  |  |  |
+------------------------------------------------------+--------+--+--+--+--+
| > If SP1 = BS or TL and SP1PER = 100                 | > Stnn |  |  |  |  |
+------------------------------------------------------+--------+--+--+--+--+
| > And CC \>50% and HT \>12m                          |        |  |  |  |  |
+------------------------------------------------------+--------+--+--+--+--+
|                                                      |        |  |  |  |  |
+------------------------------------------------------+--------+--+--+--+--+
| > If SP1 = BS or TL and SP2 = TL or BS               | > Stnn |  |  |  |  |
+------------------------------------------------------+--------+--+--+--+--+
| > And CC \>50% and HT \>12m                          |        |  |  |  |  |
+------------------------------------------------------+--------+--+--+--+--+
|                                                      |        |  |  |  |  |
+------------------------------------------------------+--------+--+--+--+--+
| > If SP1 = WB or MM or EC or BA                      | > Stnn |  |  |  |  |
+------------------------------------------------------+--------+--+--+--+--+

> If SP1 = BS or TL and SP2 = TL or BS

Ftnn

> And CC \<50%
>
> If SP1 = TL and SP1PER = 100

Ftnn

> And CC = any and HT \<12m
>
> **4.2 Non-Treed Wetlands**
>
> First, always check to see if there are non-treed wetland codes in the
> WETECO1 field. If there are then see Section 2.0 for translation
> rules. If there are not any codes then key on Layer 1 for moisture
> regime (MR) code wet (W) and NNF\_ANTH (natural non-forested and
> anthropogenic attributes). If there is a veteran layer (CANLAY with
> code V), then go to Layer 2 (SEQ 2) and follow the same steps. There
> are three categories for NNF\_ANTH: Natural Non-Treed, Natural
> Non-Vegetated, and Anthropogenic. No wetland translation is necessary
> for Anthropogenic.

+-----------------------------------------------+--------+--+--+
| **4.2.1 Natural Non-Vegetated**               |        |  |  |
+===============================================+========+==+==+
| NWF (Flooded Uplands)                         | > Mong |  |  |
+-----------------------------------------------+--------+--+--+
| **4.2.2 Natural Non-Treed**                   |        |  |  |
+-----------------------------------------------+--------+--+--+
| First key moisture regime MR = W, then:       |        |  |  |
+-----------------------------------------------+--------+--+--+
| SO, SC and crown closure \> 3                 | > Sons |  |  |
+-----------------------------------------------+--------+--+--+
|                                               |        |  |  |
+-----------------------------------------------+--------+--+--+
| HG, HF, HU, and SO, SC with crown closure \<3 | > Mong |  |  |
+-----------------------------------------------+--------+--+--+
| BR                                            | > Fonn |  |  |
+-----------------------------------------------+--------+--+--+
| CL                                            | > Bonn |  |  |
+-----------------------------------------------+--------+--+--+

> **Ontario FRI and FRI FIM**
>
> The Ontario NBI (Whitefeather and Mishkeegogamang/Eabametoong) is not
> included because those inventories already have a wetland field that
> is based on the Alberta Wetland Inventory system on which the CAS
> wetland scheme is based. The FRI may or may not have an assigned
> ecosite for each polygon. If there is not an ecosite, then only a
> partial picture of wetland can be derived because FRI does not have a
> moisture regime field and productive forested wetlands cannot be
> determined from FRI attributes alone. Also, bogs and marshes cannot be
> separated from fens.
>
> **1.0 Non Productive Forest Land**
>
> Bogs cannot be separated from fens. If there is no ecosite then key on
> MNRCODE. This field will identify the non productive treed and non
> treed polygons.

+---------------+-------------------+--------+
| > MNRCODE 310 | > Treed Muskeg    | > Ftnn |
+===============+===================+========+
| > MNRCODE 311 | > Open Muskeg     | > Fons |
+---------------+-------------------+--------+
| > MNRCODE 312 | > Brush and Alder | > Sons |
+---------------+-------------------+--------+
|               |                   |        |
+---------------+-------------------+--------+

**2.0 Productive Forest Land**

Some productive forest wetlands can be generalized and identified using
species.

+----------------------------------------------+--------+
| If SPC is mixed SbL or LSb or LSbCe or SbLCe | > Stnn |
+==============================================+========+
| If SPC is mixed CeL or LCe or CeLSb or CeSbL | > Stnn |
+----------------------------------------------+--------+
| If SPC is L and SPC% is 100                  | > Stnn |
+----------------------------------------------+--------+
| If SPC is Ab and SPC% is 100                 | > Stnn |
+----------------------------------------------+--------+
| If SPC is mixed BwL or LBw or BwCe or CeBw   | > Stnn |
+----------------------------------------------+--------+
| Short comings include:                       |        |
+----------------------------------------------+--------+
| > Pure Sb wetlands are not identified        |        |
+----------------------------------------------+--------+
| > Many Bw wetlands are not identified        |        |
+----------------------------------------------+--------+
| > Some SbL are upland                        |        |
+----------------------------------------------+--------+

**3.0 Ecosite**

FRI FIM inventories after 2007 will use the new harmonized ecosites for
Ontario (224 ecosites).

FRI prior to 2008 will use the regional ecosite codes.

+-----------------------+--------+
| **3.1 NW Ontario**    |        |
+=======================+========+
| Es 34                 | > Btnn |
+-----------------------+--------+
| Es 35, 36, 37, 38     | > Stnn |
+-----------------------+--------+
| Es 38                 | > Stnn |
+-----------------------+--------+
| Es 40                 | > Ftnn |
+-----------------------+--------+
| Es 41, 42             | > Fons |
+-----------------------+--------+
| Es 43, 45             | > Fong |
+-----------------------+--------+
| Es 44                 | > Sons |
+-----------------------+--------+
| Es 46, 47, 48, 49, 50 | > Mong |
+-----------------------+--------+

Es 51, 52, 53, 54, 55, 56 Oonn

Short comings: Es 35 and 36 can be fens (Ftnn) or a complex of bogs and
fens.

+--------------------+--------+--------+
| **3.2 NE Ontario** |        |        |
+====================+========+========+
| Es 11              | > Btnn |        |
+--------------------+--------+--------+
| Es 12, 13r         | > Stnn |        |
+--------------------+--------+--------+
| Es                 | > 13p  | > Ftnn |
+--------------------+--------+--------+
| Es                 | > 14   | > Btnn |
+--------------------+--------+--------+

NE Ontario does not identify non treed wetland; therefore, will need to
key on FRI codes OM (Open Muskeg -- Fons) and BA (Brush and Alder --
Sons). Marsh and bogs are included within OM and cannot be identified.

+-------------------------+------------------+--------+
| **3.3 Central Ontario** |                  |        |
+=========================+==================+========+
| Es                      | > 31             | > Ftnn |
+-------------------------+------------------+--------+
| Es                      | > 32, 33, and 34 | > Stnn |
+-------------------------+------------------+--------+

Central Ontario does not identify non treed wetlands; therefore, will
need to key on FRI codes OM (Open Muskeg -- Fons) and BA (Brush and
Alder -- Sons). Marsh and bogs are included within OM and cannot be
identified.

**3.4 Ecosites of Ontario (Harmonized ecosites)**

Ecosite number is preceded by a geographic range (Single letter code):
A=Sub- arctic, B=Boreal, G=Great Lakes -- St. Lawrence, and S=Southern;
a vegetation cover modifier follows the ecosite code (Single or double
letter code): Tt=Tall Treed, Tl=Low treed, S=Shrub, N=Non Woody, and
X=Non Vegetated; e.g. B126Tl.

+-------------+--------+
| 126         | > Btnn |
+=============+========+
| 127 to 133  | > Stnn |
+-------------+--------+
| 222 to 224  | > Stnn |
+-------------+--------+
| 134 and 135 | > Sons |
+-------------+--------+
| 136         | > Fons |
+-------------+--------+
| 137 and 138 | > Bonn |
+-------------+--------+
| 139 to 141  | > Ftnn |
+-------------+--------+
| 142 to 145  | > Mong |
+-------------+--------+
| 146         | > Fong |
+-------------+--------+
| 145         | > Fons |
+-------------+--------+
| 148 to 153  | > Mong |
+-------------+--------+

**Quebec Troisième Inventaire Écoforestier**

Wetlands must be determined from a number of sources to get as complete
a wetland picture as possible. General or more detailed wetland types
can be derived depending on data available. Two methods are possible;
one uses the moisture regime or drainage type without or with
combination of other cover type or forest attributes; the other method
uses ecosite. More than one method or combination of attributes may be
required. For example, polygons with a moisture regime and those
identified as unproductive should be combined, or ecosite provides data
for forested areas only.

> **1.0 General Wetland (W)**
>
> A general CAS wetland code „W‟ can be assigned to all polygons that
> have a moisture regime assigned to them. All polygons with RHY\_CO of
> 5 can be assigned CAS code „W‟. These will most likely be forested
> polygons. See Section 2.0 for unproductive forests wetland derivation.
>
> A general CAS wetland code „W‟ can be assigned to all polygons that
> have a drainage class assigned to them. If code classe de drainage
> (CDR\_CO) is code 6, then a general CAS wetland code „W‟ can be
> assigned.
>
> **2.0** **Unproductive Terrain**
>
> Unproductive forest lands are identified in Code de Terrain. If
> TER\_CO is AL and moisture is wet then wetland = Sons or W if a
> general code is preferred. If TER\_CO is DH then wetland = W. DH
> includes open and semi open polygons, further differentiation is not
> possible.
>
> **3.0 Forested Wetlands**
>
> Forested wetlands can be assigned a more descriptive wetland code
> other than W. Key on moisture regime and species.
>
> If régimes hydriques (RHY\_CO) is code 5 (Hydrique -- wet), then:
>
> If GES\_CO is EE and class de densité (CDE\_CO) = D and class de
> hauteur (CHA\_CO) = 4, 5, or 6 Btnn
>
> If GES\_CO is EC, EPu, EMe, RMe, SE, ES, RE, MeE, MeC and classe de
> densité is C, B, or A and classe de hauteur is 3, 2, or 1, then
> wetland is Stnn
>
> If GES\_CO is EE or MeMe and classe de densité is C, B, or A and
> classe de hauteur is any, then Stnn
>
> If GES\_CO is CC, CPu, CE, CMe, RC, SC, CS, PuC, BbBb, EBb, BbBbE,
> BbE, Bb1E, then Stnn
>
> If GES\_CO is EMe or MeE and classe de densité is D then Ftnn
>
> If GES\_CO is MeMe and classe de densité is any and classe de hauteur
> is 4, 5, or 6: Ftnn
>
> Any hardwoods (Fnc, Bj, Fh, Ft, Bb, Bb1, Pe, Pe1, Fi) or hardwood mix
> with wet moisture: Stnn
>
> **4.0 Ecosite**
>
> If have ecosite (TEC\_CO\_TEC) code type écologique, then wetland can
> be derived for forested ecosites only. Other sources will be required
> to include non forest ecosites or polygons (also see Terrains
> Improductifs for non forest wetlands).

+---------+-------------------------------------------------+--------+
| > RS 37 | > Black spruce-fir sphagnum on mineral          | > Stnn |
+=========+=================================================+========+
| > RS38  | > Black spruce-fir sphagnum on organic          | > Ftnn |
+---------+-------------------------------------------------+--------+
| > RS39  | > Black spruce-fir sphagnum on organic          | > Stnn |
+---------+-------------------------------------------------+--------+
| > RS18  | > Cedar-fir on mineral                          | > Stnn |
+---------+-------------------------------------------------+--------+
| > RE37  | > Black spruce sphagnum on mineral              | > Stnn |
+---------+-------------------------------------------------+--------+
| > RE38  | > Black spruce sphagnum on organic minerotrophe | > Ftnn |
+---------+-------------------------------------------------+--------+

+------+------------------------------------------------+--------+
| RE39 | > Black spruce sphagnum on organic ombrotrophe | > Btnn |
+======+================================================+========+
| RC38 | > Cedar fir                                    | > Stnn |
+------+------------------------------------------------+--------+
| MJ18 | > Yellow birch fir sugar maple on organic soil | > Stnn |
+------+------------------------------------------------+--------+
| MF18 | > Black ash fir on organic or mineral          | > Stnn |
+------+------------------------------------------------+--------+

A number of ecosites have a range from xeric to hydric. The hydric
polygons cannot be differentiated from the upland polygons without other
sources such as moisture regime. If have a moisture regime of code 5
then the following ecosites will be Stnn: FF 10, 20, 30, 50, 60; FC 10,
MJ 10, MS 10, 20, 40, 60, 70; RB 50; RP 10; RS 10, 20, 20s, 40, 50, 70;
RT 10; RE 20, 40, 70

**Prince Edward Island**

Wetland can be derived from two sources; the land use code or the
wetland cover class.

**1.0** **Land Use Code**

A general CAS wetland code can be assigned if a sub code is identified
as part of the land use code. If Land Use Code is FOR (Forestry) and Sub
Code is WET (Wetland), then assign a CAS wetland code W. If Land Use
Code is WET (Wetland) and Sub Code is FOR (Forest), then assign a CAS
wetland code W.

+----------------------------------------+---------------------------+--------+
| **2.0**                                | > **Wetland Cover Class** |        |
+========================================+===========================+========+
| Key on Cover Class with wetland codes: |                           |        |
+----------------------------------------+---------------------------+--------+
| BOW                                    | > Bog                     | > Btnn |
+----------------------------------------+---------------------------+--------+
| BKW                                    | > Brackish Marsh          | > Eonn |
+----------------------------------------+---------------------------+--------+
| DMW                                    | > Deep Marsh              | > Mong |
+----------------------------------------+---------------------------+--------+
| MDW                                    | > Meadow                  | > Mong |
+----------------------------------------+---------------------------+--------+
| SAW                                    | > Salt Marsh              | > Mcng |
+----------------------------------------+---------------------------+--------+
| SFW                                    | > Seasonally Flooded Flat | > Tmnn |
+----------------------------------------+---------------------------+--------+
| SMW                                    | > Shallow Marsh           | > Mong |
+----------------------------------------+---------------------------+--------+
| SSW                                    | > Shrub Swamp             | > Sons |
+----------------------------------------+---------------------------+--------+
| WSW                                    | > Wooded Swamp            | > Stnn |
+----------------------------------------+---------------------------+--------+

**New Brunswick**

The New Brunswick Forest Inventory Classification System identifies a
wetland category. Use fresh water (F) and Coastal (C) wetland
identifiers. First locate wetland classes and vegetation cover types.
Key on Freshwater (F) and Coastal (C) Wetland/Feature Type, then:

+-----------------------+-----------------------+-----------------------+
| If wetland Class is:  |                       |                       |
+=======================+=======================+=======================+
| AB                    | > Aquatic Bed         | > Oonn                |
+-----------------------+-----------------------+-----------------------+
| BO                    | > Bog and vegetation  | > Btnn                |
|                       | > cover type= FS      |                       |
+-----------------------+-----------------------+-----------------------+
| BO                    | > Bog and vegetation  | > Bons                |
|                       | > cover type= SV      |                       |
+-----------------------+-----------------------+-----------------------+
| FE                    | > Fen and vegetation  | > Ftnn                |
|                       | > cover type=FH       |                       |
+-----------------------+-----------------------+-----------------------+
| FE                    | > Fen and vegetation  | > Ftnn                |
|                       | > cover type=FS       |                       |
+-----------------------+-----------------------+-----------------------+
| FE                    | > Fen and vegetation  | > Fons                |
|                       | > cover type=AW       |                       |
+-----------------------+-----------------------+-----------------------+
| FE                    | > Fen and vegetation  | > Fons                |
|                       | > cover type=SV       |                       |
+-----------------------+-----------------------+-----------------------+
| FM                    | > Freshwater Marsh    | > Mong                |
+-----------------------+-----------------------+-----------------------+
| FW                    | > Forested Wetland    | > Stnn                |
+-----------------------+-----------------------+-----------------------+
| FW                    | > Forested Wetland    | > Oonn                |
|                       | > with Impoundment    |                       |
|                       | > Modifier (IM)       |                       |
+-----------------------+-----------------------+-----------------------+
| SB                    | > Shrub Wetland       |                       |
|                       | > (includes alders on |                       |
|                       | > poor sites (AP) in  |                       |
|                       | > FOREST Sons         |                       |
+-----------------------+-----------------------+-----------------------+
| CM                    | > Coastal Marsh and   | > Mcng                |
|                       | > vegetation cover    |                       |
|                       | > type= FV            |                       |
+-----------------------+-----------------------+-----------------------+
| TF                    | > Tidal Flat and      | > Tmnn                |
|                       | > vegetation cover    |                       |
|                       | > type= FV or FU      |                       |
+-----------------------+-----------------------+-----------------------+

**Nova Scotia**

The Nova Scotia Spatially Referenced Forest Resources (SRFR) data base
recognizes wetland within the non-forest categories. Forested wetlands
are not identified and there is no moisture regime attribute to help
derive forested wetlands; therefore, focus is placed on typical wetland
tree species.

**1.0** **Non-Forest**

Key on the FOR/NON 4-digit code, the last two digits identifies forest
and non-forest categories

+-----------------------+-----------------------+-----------------------+
| in which wetlands are |                       |                       |
| included.             |                       |                       |
+=======================+=======================+=======================+
| Non-forest code:      |                       |                       |
+-----------------------+-----------------------+-----------------------+
| 70                    | > Wetland General     |                       |
|                       | > (any wet area other |                       |
|                       | > than open and treed |                       |
|                       | > bog) W              |                       |
+-----------------------+-----------------------+-----------------------+
| 71                    | > Beaver Flowage      | > Mong                |
+-----------------------+-----------------------+-----------------------+
| 72                    | > Open Bog            | > Bons                |
+-----------------------+-----------------------+-----------------------+
| 73                    | > Treed Bog           | > Btnn                |
+-----------------------+-----------------------+-----------------------+
| 74                    | > Ocean Wetland       | > Ecnn                |
+-----------------------+-----------------------+-----------------------+
| 75                    | > Wetland in Lake     | > Mong                |
+-----------------------+-----------------------+-----------------------+

The treed bog category includes treed fens and treed swamps. The tree
species are not identified; therefore, no additional differentiation is
possible.

**2.0** **Forest**

Brush and alders are identified in this category, moisture cannot be
identified; therefore, upland verses wetland categories cannot be
determined. Key on FOREST codes followed by tree species and tree
attributes. Typical wetland tree species and mixes have been chosen to

> identify possible wetland forested polygons. The short comings are
> that brush and alder types could include upland moist polygons. Pure
> black spruce stands are not included because they can also be upland
> polygons.

+---------+---------+---------+---------+---------+---------+---------+
| 33      | > Brush | > Sons  |         |         |         |         |
|         | > and   |         |         |         |         |         |
|         | > Speci |         |         |         |         |         |
|         | es=     |         |         |         |         |         |
|         | > BS,   |         |         |         |         |         |
|         | > TL,   |         |         |         |         |         |
|         | > EC,   |         |         |         |         |         |
|         | > WB,   |         |         |         |         |         |
|         | > YB,   |         |         |         |         |         |
|         | > and   |         |         |         |         |         |
|         | > AS    |         |         |         |         |         |
+=========+=========+=========+=========+=========+=========+=========+
| 38, 39  | > Sons  |         |         |         |         |         |
| Alders  |         |         |         |         |         |         |
| and     |         |         |         |         |         |         |
| species |         |         |         |         |         |         |
| =       |         |         |         |         |         |         |
| BS, TL, |         |         |         |         |         |         |
| EC, WB, |         |         |         |         |         |         |
| YB, and |         |         |         |         |         |         |
| AS      |         |         |         |         |         |         |
+---------+---------+---------+---------+---------+---------+---------+
| 00      | > Natur |         |         |         |         |         |
|         | al      |         |         |         |         |         |
|         | > Stand |         |         |         |         |         |
|         | > and   |         |         |         |         |         |
|         | > Speci |         |         |         |         |         |
|         | es=     |         |         |         |         |         |
|         | > TL(10 |         |         |         |         |         |
|         | 0%)     |         |         |         |         |         |
|         | > or    |         |         |         |         |         |
|         | > TLBS  |         |         |         |         |         |
|         | > or    |         |         |         |         |         |
|         | > TLWB, |         |         |         |         |         |
+---------+---------+---------+---------+---------+---------+---------+
|         | > crown | > Ftnn  |         |         |         |         |
|         | > closu |         |         |         |         |         |
|         | re      |         |         |         |         |         |
|         | > \<    |         |         |         |         |         |
|         | > 50%   |         |         |         |         |         |
|         | > and   |         |         |         |         |         |
|         | > heigh |         |         |         |         |         |
|         | t       |         |         |         |         |         |
|         | > \<12  |         |         |         |         |         |
|         | > m     |         |         |         |         |         |
+---------+---------+---------+---------+---------+---------+---------+
|         |         |         |         |         |         |         |
+---------+---------+---------+---------+---------+---------+---------+

1.  Natural Stand and Species= TL (100%) or TLBS or TLWB, crown
    > closure \> 50% Stnn

+----+--------------------------------------------------------+--------+
| 00 | > Natural Stand and Species=EC or ECTL 0r ECBS or ECWB | > Stnn |
+====+========================================================+========+
| 00 | > Natural Stand and Species=AS or ASBS or ASTL         | > Stnn |
+----+--------------------------------------------------------+--------+
| 00 | > Natural Stand and Species=BSLT                       | > Stnn |
+----+--------------------------------------------------------+--------+

> **Newfoundland and Labrador**
>
> A complete picture of wetlands cannot be derived because there is not
> an attribute for soil moisture regime; therefore, forested wetlands
> must be determined using wetland tree species. Non commercial forest
> and non-forested land have wetland classes assigned. Polygons with
> tree species that can occur in either upland or wetland situations
> (bS, tL, wB) could be assigned a wetland class.

+-----------------------+-----------------------+-----------------------+
| > **1.0**             | > **Non Commercial    |                       |
|                       | > Forest**            |                       |
+=======================+=======================+=======================+
| > Key on Biophysical  |                       |                       |
| > Class = wet (W):    |                       |                       |
+-----------------------+-----------------------+-----------------------+
| > If Non Commercial   | > Stnn                |                       |
| > Forest code = S     |                       |                       |
| > (softwood scrub)    |                       |                       |
+-----------------------+-----------------------+-----------------------+
| > If Non Commercial   | > Stnn                |                       |
| > Forest code = H     |                       |                       |
| > (hardwood scrub)    |                       |                       |
+-----------------------+-----------------------+-----------------------+
| > **2.0**             | > **Non-Forested      |                       |
|                       | > Land**              |                       |
+-----------------------+-----------------------+-----------------------+
| > Organic Bog (symbol | > Bons                |                       |
| > or code)            |                       |                       |
+-----------------------+-----------------------+-----------------------+
| > Treed Bog (symbol   | > Btnn                |                       |
| > or code)            |                       |                       |
+-----------------------+-----------------------+-----------------------+
| > Wet Bog (symbol or  | > Mong                |                       |
| > code)               |                       |                       |
+-----------------------+-----------------------+-----------------------+
| > **3.0**             | > **Forest Land**     |                       |
+-----------------------+-----------------------+-----------------------+
| > If species is bStL  | > Stnn                |                       |
| > or bStLbF or bStLwB |                       |                       |
+-----------------------+-----------------------+-----------------------+
| > If species is tL or | > Stnn                |                       |
| > tLbF or tLwB or     |                       |                       |
| > tLbS or tLbSbF or   |                       |                       |
| > tLbSwB              |                       |                       |
+-----------------------+-----------------------+-----------------------+
| > If species is wBtL  | > Stnn                |                       |
| > or wBtLbS or wBbStL |                       |                       |
+-----------------------+-----------------------+-----------------------+

**4.0** **Ecosite**

Forested wetland ecosite data may be available based on the Forest Site
Classification Manual

-- Damman Forest Types of Newfoundland. Non forested wetland ecosites
are not included (Except some shrub types). Transition to bog types (Sks
23 and Skn 22) and seepage sites (Bt 32 and Mg 30) are not included.

+-------+--------------------------------------------------------------+--------+
| Ss 12 | > Sphagnum -- Black Spruce                                   | > Btnn |
+=======+==============================================================+========+
| Sc 18 | > Carex -- Black Spruce                                      | > Ftnn |
+-------+--------------------------------------------------------------+--------+
| So 19 | > Osmunda -- Black Spruce                                    | > Ftnn |
+-------+--------------------------------------------------------------+--------+
| Al 31 | > Lycopodium -- Alder Swamp                                  | > Stnn |
+-------+--------------------------------------------------------------+--------+
| K 33  | > Kalmia Heath -- Sphagnum -- Kalmia or Sphagnum -- Empetrum | > Sons |
+-------+--------------------------------------------------------------+--------+

**Yukon Territories**

> **Yukon Vegetation Inventory Version 2.1**

Key on soil moisture regime, then use forested and non-forested
categories. Two options are possible: one identifies a general wetland
assignment that only identifies whether a polygon is wetland or not; the
other option provides more detail within wetland types.

**1.0** **General Wetland**

If soil moisture regime (SMR) = W or A, then assign CAS wetland code W.
All forested and non-forested wetland types can be identified with a
general wetland category.

+-----------------------+-----------------------+-----------------------+
| **2.0**               | > **Non-Forested      |                       |
|                       | > Land**              |                       |
+=======================+=======================+=======================+
| Soil Moisture Regime  |                       |                       |
| = W (wet) and:        |                       |                       |
+-----------------------+-----------------------+-----------------------+
| If cover type class   | > Sons                |                       |
| (CLASS) = S           |                       |                       |
+-----------------------+-----------------------+-----------------------+
| If cover type class   | > Mong                |                       |
| (CLASS) =H            |                       |                       |
+-----------------------+-----------------------+-----------------------+
| If cover type class   | > Sons                |                       |
| (CLASS) =M            |                       |                       |
+-----------------------+-----------------------+-----------------------+
| If cover type class   | > Fons                |                       |
| (CLASS) =C            |                       |                       |
+-----------------------+-----------------------+-----------------------+
| Soil Moisture Regime  | > Mong                |                       |
| = A (aquatic)         |                       |                       |
+-----------------------+-----------------------+-----------------------+
| **3.0**               | > **Forest Land**     |                       |
+-----------------------+-----------------------+-----------------------+
| Soil Moisture Regime  |                       |                       |
| (SMR) = W:            |                       |                       |
+-----------------------+-----------------------+-----------------------+
| If species 1 (SP1) =  |                       |                       |
| SB and SP1PER = 100   |                       |                       |
+-----------------------+-----------------------+-----------------------+
| And crown closure     | > Btnn                |                       |
| (CC) \< 50% and       |                       |                       |
| height (AVG\_HT) \<   |                       |                       |
| 12 m                  |                       |                       |
+-----------------------+-----------------------+-----------------------+

If species 1 (SP1) = SB and SP1PER = 100

And crown closure (CC) [\>]{.underline} 50% and \<70% and height
(AVG\_HT) [\>]{.underline} 12 m Stnn

![](media/image2.jpeg){width="6.541666666666667in"
height="2.013888888888889e-2in"}

+-----------+-----------+-----------+-----------+-----------+-----------+
| If        | > (SP1) = |           |           |           |           |
| species 1 | > SB and  |           |           |           |           |
|           | > SP1PER  |           |           |           |           |
|           | > = 100   |           |           |           |           |
+===========+===========+===========+===========+===========+===========+
| And crown | > Sfnn    |           |           |           |           |
| closure   |           |           |           |           |           |
| (CC) \>   |           |           |           |           |           |
| 70% and   |           |           |           |           |           |
| height    |           |           |           |           |           |
| (AVG\_HT) |           |           |           |           |           |
| \> 12 m   |           |           |           |           |           |
+-----------+-----------+-----------+-----------+-----------+-----------+
|           |           |           |           |           |           |
+-----------+-----------+-----------+-----------+-----------+-----------+
| If SP1 =  |           |           |           |           |           |
| SB or L   |           |           |           |           |           |
| and SP2 = |           |           |           |           |           |
| L or SB   |           |           |           |           |           |
+-----------+-----------+-----------+-----------+-----------+-----------+
| And crown | > Ftnn    |           |           |           |           |
| closure   |           |           |           |           |           |
| (CC) \<   |           |           |           |           |           |
| 50% and   |           |           |           |           |           |
| height    |           |           |           |           |           |
| (AVG\_HT) |           |           |           |           |           |
| \< 12 m   |           |           |           |           |           |
+-----------+-----------+-----------+-----------+-----------+-----------+
|           |           |           |           |           |           |
+-----------+-----------+-----------+-----------+-----------+-----------+
| If SP1 =  |           |           |           |           |           |
| SB or L   |           |           |           |           |           |
| or W and  |           |           |           |           |           |
| SP2 = L   |           |           |           |           |           |
| or SB or  |           |           |           |           |           |
| W         |           |           |           |           |           |
+-----------+-----------+-----------+-----------+-----------+-----------+
| And crown | > Stnn    |           |           |           |           |
| closure   |           |           |           |           |           |
| (CC) \>   |           |           |           |           |           |
| 50% and   |           |           |           |           |           |
| height    |           |           |           |           |           |
| (AVG\_HT) |           |           |           |           |           |
| \> 12 m   |           |           |           |           |           |
+-----------+-----------+-----------+-----------+-----------+-----------+
| If        | > (SP1) = |           |           |           |           |
| species 1 | > L and   |           |           |           |           |
|           | > SP1PER  |           |           |           |           |
|           | > = 100   |           |           |           |           |
+-----------+-----------+-----------+-----------+-----------+-----------+
| And crown | > Ftnn    |           |           |           |           |
| closure   |           |           |           |           |           |
| (CC) \<   |           |           |           |           |           |
| 50%       |           |           |           |           |           |
+-----------+-----------+-----------+-----------+-----------+-----------+
|           |           |           |           |           |           |
+-----------+-----------+-----------+-----------+-----------+-----------+
| If        | > (SP1) = |           |           |           |           |
| species 1 | > L or W  |           |           |           |           |
|           | > and     |           |           |           |           |
|           | > SP1PER  |           |           |           |           |
|           | > = 100   |           |           |           |           |
+-----------+-----------+-----------+-----------+-----------+-----------+
| And crown | > Stnn    |           |           |           |           |
| closure   |           |           |           |           |           |
| (CC) \>   |           |           |           |           |           |
| 50% and   |           |           |           |           |           |
| \< 70%    |           |           |           |           |           |
+-----------+-----------+-----------+-----------+-----------+-----------+
| If        | > (SP1) = |           |           |           |           |
| species 1 | > L or W  |           |           |           |           |
|           | > and     |           |           |           |           |
|           | > SP1PER  |           |           |           |           |
|           | > = 100   |           |           |           |           |
+-----------+-----------+-----------+-----------+-----------+-----------+
| And crown | > Sfnn    |           |           |           |           |
| closure   |           |           |           |           |           |
| (CC) \>   |           |           |           |           |           |
| 70%       |           |           |           |           |           |
+-----------+-----------+-----------+-----------+-----------+-----------+

> **Northwest Territories**
>
> **Forest Vegetation Inventory Versions 2.1 and 3.0**
>
> Three options are possible depending on level of detail required and
> whether the attributes are recorded. The first option provides a
> general level that identifies the polygon as being a wetland or not.
> The second option looks at the forest and non-forest attributes to
> derive wetland and the third option looks at whether the optional
> wetland class has been recorded.
>
> **1.0** **General Wetland**
>
> If LANDPOS = W (wetland), then assign CAS wetland code W.
>
> **2.0** **Wetland From Forest Attributes**
>
> **2.1** **Non-Forested Polygons**
>
> Stand Structure (STRUCTURE) = S
>
> Soil Moisture Regime (Moisture) = sd (subhydric - wet) or hd (hydric
> -- very wet):

+------------------------------------------------------------+--------+
| > Type Class (TYPECLAS) = ST or SL                         | > Sons |
+============================================================+========+
| > Type Class (TYPECLAS) =HG or HF or HE                    | > Mong |
+------------------------------------------------------------+--------+
| > Type Class (TYPECLAS) =BM                                | > Fong |
+------------------------------------------------------------+--------+
| > Type Class (TYPECLAS) =BL or BY                          | > Boxc |
+------------------------------------------------------------+--------+
| > Stand Structure (STRUCTURE) = H (Horizontal)             |        |
+------------------------------------------------------------+--------+
| > Soil Moisture Regime (Moisture) = sd (subhydric - wet):  |        |
+------------------------------------------------------------+--------+
| > TYPECLAS or MINTYPCLS = SL or HG                         | > Boxc |
+------------------------------------------------------------+--------+
| > Stand Structure (STRUCTURE) = H (Horizontal)             |        |
+------------------------------------------------------------+--------+
| > Soil Moisture Regime (Moisture) = hd (hydric -very wet): |        |
+------------------------------------------------------------+--------+
| > TYPECLAS or MINTYPCLS = HG                               | > Mong |
+------------------------------------------------------------+--------+
| > Stand Structure (STRUCTURE) = M (Multi-layered)          |        |
+------------------------------------------------------------+--------+
|                                                            |        |
+------------------------------------------------------------+--------+

+----------------------------------------------------+--------+--+--+
| Soil Moisture Regime (Moisture) = sd or hd:        |        |  |  |
+====================================================+========+==+==+
| TYPECLAS = SL or ST                                | > Fons |  |  |
+----------------------------------------------------+--------+--+--+
| > **2.2 Forest Land**                              |        |  |  |
+----------------------------------------------------+--------+--+--+
| If Stand Structure (STRUCTURE) = M or C or H, and  |        |  |  |
+----------------------------------------------------+--------+--+--+
| MINTYPCLS = SL, and                                |        |  |  |
+----------------------------------------------------+--------+--+--+
| Soil Moisture Regime (SMR) = sd, and               |        |  |  |
+----------------------------------------------------+--------+--+--+
| Species 1 (SP1) = Sb or Pj and SP1PER = 100%or     |        |  |  |
+----------------------------------------------------+--------+--+--+
| SP1 =Sb or Pj and SP2 = Pj or Sb                   |        |  |  |
+----------------------------------------------------+--------+--+--+
| and Crown Closure (CC) \< 50% and HEIGHT \<8 m     | > Btxc |  |  |
+----------------------------------------------------+--------+--+--+
| If Stand Structure (STRUCTURE) = S, and            |        |  |  |
+----------------------------------------------------+--------+--+--+
| Soil Moisture Regime (SMR) = sd or hd, and         |        |  |  |
+----------------------------------------------------+--------+--+--+
| Species 1 (SP1) = Sb or Lt, and SP1PER = 100%, and |        |  |  |
+----------------------------------------------------+--------+--+--+
| Crown Closure (CC) \> 50% and \< 70%               | > Stnn |  |  |
+----------------------------------------------------+--------+--+--+
| If Soil Moisture Regime (SMR) = sd or hd, and      |        |  |  |
+----------------------------------------------------+--------+--+--+
| Species 1 (SP1) = Sb or Lt, and                    |        |  |  |
+----------------------------------------------------+--------+--+--+
| Crown Closure (CC) \> 70%                          | > Sfnn |  |  |
+----------------------------------------------------+--------+--+--+
| If Soil Moisture Regime (SMR) = sd or hd, and      |        |  |  |
+----------------------------------------------------+--------+--+--+
| Species 1 (SP1) = Sb or Lt and SP2 = Lt or Sb, and |        |  |  |
+----------------------------------------------------+--------+--+--+
| > HEIGHT \< 12 m                                   | > Ftnn |  |  |
+----------------------------------------------------+--------+--+--+
| If Soil Moisture Regime (SMR) = sd or hd, and      |        |  |  |
+----------------------------------------------------+--------+--+--+
| Species 1 (SP1) = Sb or Lt and SP2 = Lt or Sb, and |        |  |  |
+----------------------------------------------------+--------+--+--+
| > HEIGHT \> 12 m                                   | > Stnn |  |  |
+----------------------------------------------------+--------+--+--+
|                                                    |        |  |  |
+----------------------------------------------------+--------+--+--+
| If Soil Moisture Regime (SMR) = hd, and            |        |  |  |
+----------------------------------------------------+--------+--+--+
| Species 1 (SP1) = Sb or Lt, and SP1PER = 100%, and |        |  |  |
+----------------------------------------------------+--------+--+--+
| Crown Closure (CC) \< 50%                          | > Ftnn |  |  |
+----------------------------------------------------+--------+--+--+
| If Soil Moisture Regime (SMR) = sd or hd, and      |        |  |  |
+----------------------------------------------------+--------+--+--+
| Species 1 (SP1) = Sb or Lt or Bw or Sw             |        |  |  |
+----------------------------------------------------+--------+--+--+
| and SP2 = Lt or Sb or Bw or Sw and CC \> 50%       | > Ftnn |  |  |
+----------------------------------------------------+--------+--+--+
| If Soil Moisture Regime (SMR) = sd or hd, and      |        |  |  |
+----------------------------------------------------+--------+--+--+
| Species 1 (SP1) = Bw or Po                         | > Stnn |  |  |
+----------------------------------------------------+--------+--+--+

**3.0** **Wetland Class**

The NWT Forest Vegetation Inventory has wetland class as an option. If a
wetland class

attribute has been recorded, then:

Key on WETLAND:

+----+-------------------------------------+--------+
| We | > Wetland, no distinction           | > W    |
+====+=====================================+========+
| So | > Shallow Open Water                | > Oonn |
+----+-------------------------------------+--------+
| Ma | > Marsh                             | > Mong |
+----+-------------------------------------+--------+
| Sw | > Swamp and SP1 is populated        | > Stnn |
+----+-------------------------------------+--------+
| Sw | > Swamp and TYPECLAS + SL or ST     | > Sons |
+----+-------------------------------------+--------+
| Fe | > Fen and SP1 is populated          | > Ftnn |
+----+-------------------------------------+--------+
| Fe | > Fen and TYPECLAS = HG             | > Fong |
+----+-------------------------------------+--------+
| Fe | > Fen and TYPECLAS = SL or ST       | > Fons |
+----+-------------------------------------+--------+
| Bo | > Bog and SP1 is populated          | > Btxc |
+----+-------------------------------------+--------+
| Bo | > Bog and TYPECLAS = BY or BL or BM | > Boxc |
+----+-------------------------------------+--------+

**Wood Buffalo National Park**

Wood Buffalo National Park is a biophysical inventory completed in the
70‟s based on a mapping scale of 1:100,000. This mapping scale will
dictate that polygons will more than likely be heterogeneous rather than
homogeneous; therefore, a single polygon can include more than one
vegetation cover type or wetland vegetation cover type. Up to nine
biophysical vegetation types and up to seven vegetation plant
communities can be described for each polygon. The biophysical
vegetation and vegetation plant community codes are identical. The
position of each vegetation type within a heterogeneous polygon cannot
be determined (except when a polygon is identified with only one wetland
type or types); however, a percentage cover of each vegetation plant
community is provided. Also note that this inventory has not been
updated since the original was completed. Fire history records will need
to be accessed for a more current view of the vegetation cover.

There are a few options that can be used to identify polygons that
contain wetland types based on assessing different fields. A wetland
code will need to be derived for each of the wetland vegetation plant
communities identified for each polygon. More than one wetland type may
be identified within a polygon. The best option is to key on the
vegetation plant community field (v\#pcm) and associated vegetation
structure field (v\#str). Each polygon can have up to seven vegetation
plant communities described (along with descriptions of moisture
(v\#moi), species (v\#sp1-4), percent cover (v\#pct) and height
(v\#htc)) of which any number can be wetland types.

The bveg\# field (biophysical vegetation), identifies up to nine fields
but does not identify the percentage cover of each type; therefore, it
is recommended that this field not be used to derive wetland. The v\#pcm
fields (vegetation plant community) should be used instead. The v\#str
and v\#moi (moisture) fields can be used as a confirmation of wetland
status or used to further refine the classification such as between
treed fen and treed bog. The v\#str\# field contains several codes that
identify wetland type; however, they are redundant to the v\#pcm field
and if not identified below, they are not necessary. Vegetation
community types 21 and 22 are black spruce types but it is uncertain if
they are wetland or moist upland so they have not been included. The
v\#pct field identifies the percent cover of each vegetation plant
community in 10 percent classes.

If v\#pcm = 99

If v\#pcm = 98

If v\#pcm = 1 or 2 or 3 or 4

If v\#pcm = 7

If v\#pcm = 17

If v\#pcm = 18

If v\#pcm = 19 and v\#str = N then Ftnn and if v\#str = P then

If v\#pcm = 20

Mong

> Sons

Mong

Sons

Fong

Sons

Btnn

Stnn

**Prince Albert National Park**

Prince Albert National Park is a biophysical inventory based on 1968
photographs and a mapping scale of 1:50,000. This mapping scale will
dictate that polygons will more than likely be heterogeneous rather than
homogeneous; therefore, a single polygon can include more than one
vegetation type or wetland vegetation type. Up to three biophysical
vegetation types (including two-layered stands) and up to three ground
vegetation types can be described for each polygon. The position of each
vegetation type within a heterogeneous polygon cannot be determined
(except when a polygon is identified with only one wetland type or
types); however, a percentage cover of each vegetation plant community
is provided. Also note that this inventory has not been updated since
the original was completed. Fire history records will need to be
accessed for a more current view of the current vegetation cover.

Three cover types (including two- layered stands) and up to three ground
vegetation types (non forest) can be described for each polygon. A
wetland code will need to be derived for each of the wetland types
identified for each polygon. More than one wetland type may be
identified within a polygon. The best option is to key on the overstory
(C\#SPEC), understory (U\#SPEC) and ground vegetation (G\#SPEC) fields.

There is no moisture regime field identified; therefore, wetlands will
need to be derived or identified from other fields. Non treed wetlands
are identified in G\#SPEC fields:

+-----------------------+-----------------------+-----------------------+
| M1                    | > \[lowland (wet      | > Fong or Mong or Wo  |
|                       | > site) herb and      |                       |
|                       | > sedge cover\]       |                       |
+=======================+=======================+=======================+
| M2                    | > \[lowland (wet      | > Sons or Fong        |
|                       | > site) shrub cover\] |                       |
+-----------------------+-----------------------+-----------------------+
| FL (flooded lands)    | > Mong                |                       |
+-----------------------+-----------------------+-----------------------+

Open fen and marsh types cannot be differentiated. A choice will need to
made for M1 or M2 as to which cover type is most prevalent or a generic
wetland code (Wo) can be assigned.

Treed wetlands will need to be derived. Key on overstory C\#SPEC or
understory U\#SPEC fields with support from C\#HT (height), C\#DENS
(crown closure) and U\#HT, U\#DENS fields:

If C\#SPEC and U\#SPEC contain only PM and C\#DENS is code 1 or 2 and
C\#HT is code 1 then Btnn

If C\#SPEC and U\#SPEC contain only PM and C\#DENS is code 3 and C\#HT
is code 1, 2 or 3 then Stnn

If C\#SPEC and U\#SPEC contain only LL or PM and LL occur in either one
of the layers (i.e. must have PM and LL in one of the layers) or PM and
LL occur as mixed in either layer and C\#HT code is 1 or 3 and C\#DENS
is code 1, 3, 5 or 7 then Ftnn

If C\#SPEC and U\#SPEC contain only LL or PM and LL occur in either one
of the layers (i.e. must have PM and LL in one of the layers) or PM and
LL occur as mixed in either layer and C\#HT code is 5 or 7 and C\#DENS
is code 3 then Stnn

Note that overstory and understory may need to be combined to meet
density totals. Also, some moist or very moist upland black spruce and
larch types will be included.

**APPENDIX 1**

**CAS Wetland Classification Scheme**

+--+---------------------------------------------+---+--+
|  | > **WETLAND CLASS**                         |   |  |
+==+=============================================+===+==+
|  |                                             |   |  |
+--+---------------------------------------------+---+--+
|  | > **Bog**                                   | B |  |
+--+---------------------------------------------+---+--+
|  | > **Fen**                                   | F |  |
+--+---------------------------------------------+---+--+
|  | > **Swamp**                                 | S |  |
+--+---------------------------------------------+---+--+
|  | > **Marsh**                                 | M |  |
+--+---------------------------------------------+---+--+
|  | > **Shallow Open Water**                    | O |  |
+--+---------------------------------------------+---+--+
|  | > **Tidal Flats**                           | T |  |
+--+---------------------------------------------+---+--+
|  | > **Estuary**                               | E |  |
+--+---------------------------------------------+---+--+
|  | > **Wetland, no Distinction**               | W |  |
+--+---------------------------------------------+---+--+
|  | > **Not Wetland**                           | Z |  |
+--+---------------------------------------------+---+--+
|  | > **Blank**                                 |   |  |
+--+---------------------------------------------+---+--+
|  | > **VEGETATION MODIFIER**                   |   |  |
+--+---------------------------------------------+---+--+
|  |                                             |   |  |
+--+---------------------------------------------+---+--+
|  | > **Forested closed canopy \>70% tree**     | F |  |
+--+---------------------------------------------+---+--+
|  | > **cover**                                 |   |  |
+--+---------------------------------------------+---+--+
|  | > **Wooded open canopy \>6% - 70% tree**    | T |  |
+--+---------------------------------------------+---+--+
|  | > **cover**                                 |   |  |
+--+---------------------------------------------+---+--+
|  | > **Open Non-Treed Freshwater \<6% tree c** | O |  |
+--+---------------------------------------------+---+--+
|  | > **Open Non-Treed Coastal \< 6% tree**     | C |  |
+--+---------------------------------------------+---+--+
|  | > **cover**                                 |   |  |
+--+---------------------------------------------+---+--+
|  | > **Mud**                                   | M |  |
+--+---------------------------------------------+---+--+
|  | > **Blank**                                 |   |  |
+--+---------------------------------------------+---+--+
|  | > **WETLAND LANDFORM MODIFIER**             |   |  |
+--+---------------------------------------------+---+--+
|  |                                             |   |  |
+--+---------------------------------------------+---+--+
|  | > **Permafrost present**                    | X |  |
+--+---------------------------------------------+---+--+
|  | > **Patterning present**                    | P |  |
+--+---------------------------------------------+---+--+
|  | > **No permafrost or patterning**           | N |  |
+--+---------------------------------------------+---+--+
|  | > **Saline or alkaline present**            | A |  |
+--+---------------------------------------------+---+--+
|  | > **Blank**                                 |   |  |
+--+---------------------------------------------+---+--+
|  |                                             |   |  |
+--+---------------------------------------------+---+--+

**LOCAL LANDFORM MODIFIER**

+--------------------------------------------+---+--+--+
| **Collapse scar present in permafrost**    | C |  |  |
+============================================+===+==+==+
| **area**                                   |   |  |  |
+--------------------------------------------+---+--+--+
| **Internal lawn with islands of forested** | R |  |  |
+--------------------------------------------+---+--+--+
| **peat plateau**                           |   |  |  |
+--------------------------------------------+---+--+--+
| **Internal lawns (permafrost once**        | I |  |  |
+--------------------------------------------+---+--+--+
| **present)**                               |   |  |  |
+--------------------------------------------+---+--+--+
| **Internal lawns not present**             | N |  |  |
+--------------------------------------------+---+--+--+
| **Shrub cover \> 25%**                     | S |  |  |
+--------------------------------------------+---+--+--+
|                                            |   |  |  |
+--------------------------------------------+---+--+--+
| **Graminoids with shrub cover \< 25%**     | G |  |  |
+--------------------------------------------+---+--+--+
| **Blank**                                  |   |  |  |
+--------------------------------------------+---+--+--+

Examples:

1)  W Wetland no distinction, polygon only recognized as being a wetland
    with no further detail.

2\) Btnn treed bog (forest cover 6 %-- 70%), no permafrost and no lawns
present.

3)  Mcng Coastal marsh, vegetated with graminoids.

4)  Tmnn Tidal mud flats.

5)  BBog, no other information available.

+----+--------+--------------------------------------------------------------+
| 6) | > Btxc | > Treed bog with peat plateau permafrost and collapse scars. |
+====+========+==============================================================+
| 7) | > Ftps | > Patterned treed fen with dominant shrub                    |
+----+--------+--------------------------------------------------------------+
| 8) | > Moag | > Alkaline marsh.                                            |
+----+--------+--------------------------------------------------------------+

**APPENDIX 1**

**CAS Wetland Classification Scheme**

+--+---------------------------------------------+---+--+
|  | > **WETLAND CLASS**                         |   |  |
+==+=============================================+===+==+
|  |                                             |   |  |
+--+---------------------------------------------+---+--+
|  | > **Bog**                                   | B |  |
+--+---------------------------------------------+---+--+
|  | > **Fen**                                   | F |  |
+--+---------------------------------------------+---+--+
|  | > **Swamp**                                 | S |  |
+--+---------------------------------------------+---+--+
|  | > **Marsh**                                 | M |  |
+--+---------------------------------------------+---+--+
|  | > **Shallow Open Water**                    | O |  |
+--+---------------------------------------------+---+--+
|  | > **Tidal Flats**                           | T |  |
+--+---------------------------------------------+---+--+
|  | > **Estuary**                               | E |  |
+--+---------------------------------------------+---+--+
|  | > **Wetland, no Distinction**               | W |  |
+--+---------------------------------------------+---+--+
|  | > **Not Wetland**                           | Z |  |
+--+---------------------------------------------+---+--+
|  | > **Blank**                                 |   |  |
+--+---------------------------------------------+---+--+
|  | > **VEGETATION MODIFIER**                   |   |  |
+--+---------------------------------------------+---+--+
|  |                                             |   |  |
+--+---------------------------------------------+---+--+
|  | > **Forested closed canopy \>70% tree**     | F |  |
+--+---------------------------------------------+---+--+
|  | > **cover**                                 |   |  |
+--+---------------------------------------------+---+--+
|  | > **Wooded open canopy \>6% - 70% tree**    | T |  |
+--+---------------------------------------------+---+--+
|  | > **cover**                                 |   |  |
+--+---------------------------------------------+---+--+
|  | > **Open Non-Treed Freshwater \<6% tree c** | O |  |
+--+---------------------------------------------+---+--+
|  | > **Open Non-Treed Coastal \< 6% tree**     | C |  |
+--+---------------------------------------------+---+--+
|  | > **cover**                                 |   |  |
+--+---------------------------------------------+---+--+
|  | > **Mud**                                   | M |  |
+--+---------------------------------------------+---+--+
|  | > **Blank**                                 |   |  |
+--+---------------------------------------------+---+--+
|  | > **WETLAND LANDFORM MODIFIER**             |   |  |
+--+---------------------------------------------+---+--+
|  |                                             |   |  |
+--+---------------------------------------------+---+--+
|  | > **Permafrost present**                    | X |  |
+--+---------------------------------------------+---+--+
|  | > **Patterning present**                    | P |  |
+--+---------------------------------------------+---+--+
|  | > **No permafrost or patterning**           | N |  |
+--+---------------------------------------------+---+--+
|  | > **Saline or alkaline present**            | A |  |
+--+---------------------------------------------+---+--+
|  | > **Blank**                                 |   |  |
+--+---------------------------------------------+---+--+
|  |                                             |   |  |
+--+---------------------------------------------+---+--+

> **LOCAL LANDFORM MODIFIER**

+--------------------------------------------+---+--+--+
| **Collapse scar present in permafrost**    | C |  |  |
+============================================+===+==+==+
| **area**                                   |   |  |  |
+--------------------------------------------+---+--+--+
| **Internal lawn with islands of forested** | R |  |  |
+--------------------------------------------+---+--+--+
| **peat plateau**                           |   |  |  |
+--------------------------------------------+---+--+--+
| **Internal lawns (permafrost once**        | I |  |  |
+--------------------------------------------+---+--+--+
| **present)**                               |   |  |  |
+--------------------------------------------+---+--+--+
| **Internal lawns not present**             | N |  |  |
+--------------------------------------------+---+--+--+
| **Shrub cover \> 25%**                     | S |  |  |
+--------------------------------------------+---+--+--+
|                                            |   |  |  |
+--------------------------------------------+---+--+--+
| **Graminoids with shrub cover \< 25%**     | G |  |  |
+--------------------------------------------+---+--+--+
| **Blank**                                  |   |  |  |
+--------------------------------------------+---+--+--+

Examples:

1)  W Wetland no distinction, polygon only recognized as being a wetland
    with no further detail.

2\) Btnn treed bog (forest cover 6 %-- 70%), no permafrost and no lawns
present.

3)  Mcng Coastal marsh, vegetated with graminoids.

4)  Tmnn Tidal mud flats.

5)  BBog, no other information available.

+----+--------+--------------------------------------------------------------+
| 6) | > Btxc | > Treed bog with peat plateau permafrost and collapse scars. |
+====+========+==============================================================+
| 7) | > Ftps | > Patterned treed fen with dominant shrub                    |
+----+--------+--------------------------------------------------------------+
| 8) | > Moag | > Alkaline marsh.                                            |
+----+--------+--------------------------------------------------------------+
