jstat = require 'jStat'
fs = require 'fs'
mongo = require 'mongodb'

get_data = ->
  server = new mongo.server "127.0.0.1", 27017, {}
  client = new mongo.Db 'users', server
  relevant_user = (dbErr, collection) ->
    console.log "No connection there #{dbErr}" if dbErr
    collection.find().nextObject (err, result) -> 
      if err 
        console.log "Find action failed #{err}"
      else
        data.push result
  client.open (err, db) -> 
    client.connection "users", relevant_user
  output = []
  for data_point in data
    output.push [company.id,company.company.size,company.title,company.start_date,company.end_data] for company in data.data.positions
  return output

normalize_feature = (data) ->
  # define company size as 0 -> 
  # define title 
  titles = {}
  title['top_title_examples'] = fs.readFile '../top_level.csv', utf8, content -> top_title_examples = content
  title['senior_title_examples'] = fs.readFile '../senior_level.csv', utf8, content -> senior_title_examples = content
  title['middle_title_examples'] = fs.readFile '../middle_level.csv', utf8, content -> middle_title_examples = content
  title['junior_title_examples'] = fs.readFile '../junior_level.csv', utf8, content -> junior_title_examples = content
  title['low_title_examples'] = fs.readfile '../low_level.csv', utf8, content -> low_title_examples = content

  check_title = (title,example_titles) ->
    if title in example_titles.top_title_examples
      return 5
    if title in example_titles.senior_title_examples
      return 4
    if title in example_titles.middle_title_examples
      return 3
    if title in example_titles.junior_title_examples
      return 2
    if title in example_titles.low_title_examples
      return 1

  check_company_scale = (company_size) ->
    if company_size is "10,001+ employees"
      return 5
    if company_size is "5001-10000 employess"
      return 4
    if company_size is "1001-5000 employess"
      return 3
    if company_size is "201-1000 employess"
      return 2
    if company_size is "51-200 employess"
      return 1
    if company_size is "11-50 employess"
      return 1
    if company_size is "1-10 employess"
      return 1
  
  compute_influence = (positions, current_time) ->
    influence = []
    for poition in positions
      if position.start_time < current_time < position.end_time
        influence.push ( title_influence / 5 ) * (company_influence / 5)
      else
        influence.push 0.0
    average_influence = influence.reduce (c,i) c += i 
    average_influence = influence / influence.length

  year_start = 2005
  year_stop = 2013
  month_start = 1
  month_stop = 12
  for doc in data
    doc[1] = check_company_scale(doc[0],title)
    doc[2] = check_title(doc[2],titles)
    doc[3] = Math.round(Date(doc[3].end_time?.year,doc[3].end_time?.month).getTime / 1000)
    doc[4] = Math.round(Date(doc[4].end_time?.year,doc[4].end_time?.month).getTime / 1000)
    doc[5] = if doc[4] > 0 then doc[4] - doc[3] else 0
  feature_vector = []
  for year in [year_start..year_stop]
    for month in [month_start..month_stop]
      feature_vector.push compute_influence doc, Math.round(Date(year,month).getTime / 1000)

  return feature_vector


 
interpret_feature = (data) ->

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

position_proposal = (sample, candidates, length_suggestions) ->
  oldest_timestamp = (Math.round(Date(company.end_time?.year,company.end_time?.year).getTime / 1000) for company in sample.positions?.values?).max ( array ) -> Math.max.apply Math,array
  user_average = sample.reduce (c,i) -> c += i.company_performance_factor
  user_average = user_average / sample.length
  recommendation_score = []
  normalization_factor = candidates.reduce (c,i) -> c += i[0]
  weight_average_level = (candidate_score[0] * candidate_score[1] for candidate_score in candidates if ).reduce (c,i) -> c += i 
  feature = interpret_feature(weight_average_level)


collaborative_filtering = (test_sample, train_samples, k, dist_func) -> 
  norm_test_sample = normalized_sample(test_sample)
  dist = ( dist_func( norm_test_sample, normalized_sample( train_sample ) ) for train_sample in train_samples )
  top_k_train_samples = fetch_top_samples(train_samples,dist, k)
  probable_position = position_proposal(test_sample, top_k_train_samples)

recommend = (user) ->
  # Here comes the recommendation/prediction
  positions = get_user_data()
  features = normalize_feature(positions)
  recommendation = collaborative_filtering(user,features)
  return recommendation
