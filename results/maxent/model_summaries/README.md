Model summaries
===============

This folder contains summary statistics for the models that maxent has produced:

- [AUCValues.csv](AUCValues.csv) contains the area-under-the-curve values that were compared
  against those obtained by random sampling within the buffered species area in the 'main'
  maxent workflow
- [traits_contribution_maxent.csv](traits_contribution_maxent.csv) contains the contribution
  of each GIS layer for each species. This is necessarily a sparse matrix because most
  layers are thrown out (to avoid collinearity) during the variable selection procedure. This
  spreadsheet is produced by the variable importance workflow.
- [mean_traits_contribution_maxent.csv](mean_traits_contribution_maxent.csv) summarizes the
  results of the previous spreadsheet to obtain the importance of each variable averaged
  over all species. Also produced by the variable importance workflow.