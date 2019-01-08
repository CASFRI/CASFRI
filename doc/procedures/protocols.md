# 1. GitHub protocols

## Repositories
Two repositories were made under @edwardsmarc account:
* The [CASFRI](https://github.com/edwardsmarc/CASFRI) repository will be used for development of CASFRI v5. 
* The [PostTranslationEngine](https://github.com/edwardsmarc/postTranslationEngine) repository will be used for the development of the PostgreSQL translation engine. The engine is being developed for the CASFRI project but will be designed to work for any translation tables.

## Git client
All team members are using the GitKraken client.

## GitHub collaborative model

Initially we will use a *shared repository* model.
* All team members are assigned as collaborators on the master repositories.
* All team members can push code to the master repository.
* The creator of the master repositories (@edwardsmarc) does not need to approve pull requests.
* Each team member has a clone of the master repository on their local machine.

The recommended workflow is as follows:
1. Pull from the master repository on GitHub (e.g. press the "Pull" button in GitKraken).
2. Edit code locally.
3. Commit changes.
4. Push changes to the master repository on Github.

This model can break down if multiple people are pushing changes to the same files and merge conflict result. We don't anticipate this happening due to our small team. Team members will mostly be working on their own code. If merge conflicts become as issue we could change to a *branch and pull* model where we still use a shared repository but changes are made o branches of the repository which are then incorporated back to the master branch via pull requests. We prefer these two models over a fork and pull model which requires each user to fork a copy the master repository to their own GitHub account.

More details on these models can be found [here](http://www.goring.org/resources/project-management.html).

## Project management
* Project progress will be tracked using *Issues* in each GitHub repository. 
* A project board will group issues into *To Do*, *In progress* and *Done*. 
* A new project board will be made for each phase of the project. For example, the first project board will be specific to the first project phase ending on March 31 2019.
* Each project board should have a *Note* kept at the top of the *To Do* column listing the deliverables for that phase.
* Issues should be created by each team member as their work progresses and should follow the following rules:
  * Short, descriptive title
  * Detailed description of the work involved
  * All issues should have at least on Assignee
  * Label to indicate where the issue fits into the project (e.g. *conversion*)
  * Labels to indicate set-backs (e.g. *Help wanted*)
  * Appropriate scale
    * For example, Issue 1 could be
    > Convert/load the first FRI
    * and Issue 2 could be
    > Convert/load the remaining three FRIs
 
# 2. Documentation
All CASFRI v5 documentation will be written in markdown and version controlled on GitHub. Two options exist for writing documentation:
1. For simple documents such as this, markdown can be written directly in GitHub, or in a text editor. A .md file will be stored on GitHub. This is the preferred method for internal, non-formal documentation.
2. For formal documentation (e.g. CASFRI standards, translation engine specs etc.), RStudio should be used to create .Rmd files. This is the prefferred method for the following reasons:
  * Scripts can easily be edited to output multiple formats, this could be useful for meeting various client needs (e.g. html, pdf).
  * We can utilize R packages for displaying tables
  * Tables can be updated and edited using a csv editor rather than having to edit markdown directly
  * Multiple .Rmd files could later be combined into more complex document structures (e.g. websites, books) using RMarkdown templates.
  * The following rules should be followed when writing .Rmd files:
    1. Always output a .md file so the document can be viewed on GitHub
    2. Any external files such as csv tables should be stored in a sub-folder called *rmdTabs*
    3. Tables to be added should be stored as csv files

# 3. Software versions
Client is using:
* PostgreSQL v9.6*
* PostGIS v2.3.7  
We also need:
* GDAL/OGR v???

# 4. Backup procedures
???
