# Outlying mean index

- [standardized.averages.csv](standardized.averages.csv) contains the averages
  calculated over the pixel values directly under the true occurrences,
  normalized. No maxent or anything. **Redid this with 5 arc minute data, see below**
- [normalized_MaxEnt_values.csv](normalized_MaxEnt_values.csv) contains the 
  averages calculated over all pixels in the projection thresholded by the 90%
  percentile of occurrences ranked by suitability. Normalized.
- [normalized_raw_values.csv](normalized_raw_values.csv) contains the averages
  calculated over the occurrences (as opposed to the projected, thresholded,
  suitable pixels). Normalized.
- [niche_traits.csv](niche_traits.csv) contains the averages
  calculated over the pixel values directly under the true occurrences,
  normalized. No maxent or anything. Run with OMI.R and [config.yml](config.yml)
