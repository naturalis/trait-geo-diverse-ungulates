# trait-geo-diverse-ungulates

![](doc/Ungulates.JPG)


Project repository for the analysis of abiotic niches of Ungulates. Contains
source code (R) and data files. The overall layout is as follows:

- [script](script) - source code
- [data](data) - CSV files with species occurrences
- [results](results) - output from niche modelling (e.g. maxent output)
- [doc](doc) - documentation files

The source code that is being developed is intended to be portable such that
analysis workflows can be prototyped on laptops, while longer running analyses
can be executed in a cloud environment. From the data, all species for which
at least 10 distinct records are available (Raes & Aguirre-Gutierrez, 2018),
are analyzed. In addition to the occurrences, other input data include GIS
layers for bioclimatic variables, soil, topographic heterogeneity, and 
vegetation types. However, these are quite large files obtained from 3rd 
parties, and so we consider these immutable for this project. Hence, we store
them separately in a DropBox folder structure. From these input data types,
we model niches (e.g. using maxent), the results of which we write to the
results folder. These are then, subsequently, used for the following:

- to calculate niche overlap between pairs of species, such that we can then
  cluster species by ecological similarity
- to identify the niche dimensions that determine Ungulate distribution

![](doc/anna_karenina.gif)