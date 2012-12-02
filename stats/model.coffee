# Algorithm description
# 1. extract features : company name, type, size, year, your length of career, starting time, previous histories
# 2. normalize features : normalization
# 3. collaborative filtering

load_feature = (data_file, ) -> 
  # Load the file
  # clean up the data
  # Transform the code

normalize_feature = (data) ->
  # Feature normalization
  # Time series formulation

cosine_similarity = (sample_1, sample_2) ->
  nominator = [sample_i * sample_2[i] for sample_i, i in sample_1].reduce (a,b) -> a + b
  denominator_sample_1 = [sample_i * sample_i fro sample_i in sample_1].reduce (a,b) -> a + b
  denominator_sample_1 = Math.sqrt(denominator_sample_1)
  denominator_sample_2 = [sample_i * sample_i fro sample_i in sample_2].reduce (a,b) -> a + b
  denominator_sample_2 = Math.sqrt(denominator_sample_2)
  if denominator_sample_1 is 0.0 or denominator_sample_2 is 0.0 then 0.0 else nominator / ( denominator_sample_1 * denominator_sample_2 )

fetch_top_samples = (data,scale,k) ->
  scale_with_index = ([scale_point,index] for scale_point,i in scale)
  scale_with_index.sort (left,right) ->
    if left[0] < right[0] then -1 else 1
  sorted_indices = (sorted_item[1] for sorted_item in scale_with_index)[0:k]

position_proposal = (sample, candidates) ->
  oldest_timestamp = (Date(company.end_time?.year,company.end_time?.year).get_time / 1000  for company in sample.positions?.values?)

collaborative_filtering = (test_sample, train_samples, k, dist_func) -> 
  norm_test_sample = normalized_sample(test_sample)
  dist = ( dist_func( norm_test_sample, normalized_sample( train_sample ) ) for train_sample in train_samples )
  top_k_train_samples = fetch_top_samples(train_samples,dist, k)
  probable_position = position_proposal(test_sample, top_k_train_samples)
