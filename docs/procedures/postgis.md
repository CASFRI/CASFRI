# PostGIS and GDAL

This page describes how to install PostgreSQL/PostGIS and GDAL/OGR on a 64-bit Windows 10 machine. There are no requirements to install these in any particular order.

**Note**: This is PV's experience from December 2018; there is likely to be a different approach based on PR's experience and the requirements to have certain version numbers. Also, installing Anaconda/Python may not be necessary if there is a more suitable alternative to installing the proper version of GDAL/OGR.

### PostgreSQL/PostGIS

You can download the latest version from here:

  * https://www.enterprisedb.com/downloads/postgres-postgresql-downloads

First, select and download the latest (11.1) or agreed upon version for Windows 10 64-bit (Windows x86-64). Once downloaded, start the installation by double-clicking on the file. I selected all the default parameters and used "postgres" as the password for the "postgres" database that is created during the installation process. Towards the end of the installation, you can select extensions - namely the latest version of PostGIS. That's all there is to it!

### GDAL with Anaconda

Anaconda includes Python and various libraries that are useful for spatial data management and analysis e.g., GDAL/OGR. Specifically, the ogr2ogr utility includes most of the drivers needed to import vector datasets (e.g., shapefiles, file geodatabases) into PostGIS. You can download the latest version from here:

  * https://www.anaconda.com/download/

First, download the Python 3.7 64-Bit Graphical Installer. Once downloaded, start the installation and select the default prompts. At this point, you should be able to start the Anaconda prompt. From there, you can run various utilities, Python scripts, and install additional libraries as needed.

### GDAL without Anaconda

This is likely a better approach to avoid installing the whole Anaconda suite. First download the following package from GISInternals:
  * http://www.gisinternals.com/query.html?content=filelist&file=release-1911-x64-gdal-2-3-3-mapserver-7-2-1.zip

More details to follow from someone whose tried it...
