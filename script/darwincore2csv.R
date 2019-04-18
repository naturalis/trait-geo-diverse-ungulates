# this script takes a darwin core archive and extracts all distinct occurrences from it,
# writing them to a csv file in the data/filtered/ directory

library(finch) # reads darwincore zip file
library(dplyr) # data munging library

# what to write in the data file and output csv file name
genus.name <- "Vicugna"
species.name <- "vicugna"

# for the workflow of unpacking a zip file downloaded from gbif into the
# /data/domesticated folder these variables can be left unchanged
REPO_HOME <- paste(getwd(), "/../", sep = "")
infile.name <- sprintf("%s/data/domesticated/%s_%s/darwincore.zip", REPO_HOME, genus.name, species.name)
outfile.name <- sprintf("%s/data/filtered/%s_%s.csv", REPO_HOME, genus.name, species.name)

# read the occurrences file from darwincore archive
finch::dwca_cache$delete_all()
infile.dwca_gbif <- finch::dwca_read(infile.name, read = TRUE)
occurrences.df <- infile.dwca_gbif$data$occurrence.txt

# select, filter
occurrences.df <- dplyr::select(
  occurrences.df,
  gbif_id = gbifID,
  decimal_latitude = decimalLatitude,
  decimal_longitude = decimalLongitude
)
occurrences.df <- occurrences.df[!duplicated(occurrences.df[2:3]), ]

# add taxon name column
occurrences.df$taxon_name <- paste(genus.name, species.name)

# reorder columns
occurrences.df <- occurrences.df[, c(1, 4, 2, 3)]

# write out file
write.csv(
  occurrences.df,
  file = outfile.name,
  quote = F,
  eol = "\n",
  row.names = F
)

