# Render site
library(rmarkdown)
library(tidyverse)
unlink("site_libs", recursive=T)
render_site()
#render("data/intact.Rmd")
#render("data/disturb.Rmd")

# Update github
# git add .
# git commit -m "added new data menu with intactness page"
# git push https://github.com/prvernier/prvernier.github.io.git master
