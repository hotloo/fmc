jstat = require 'jStat'
fs = require 'fs'

normalize_feature = (data) ->
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
    average_influence = influence.reduce (c,i) -> c += i 
    average_influence = influence / influence.length

  year_start = 2000
  year_stop = 2013
  month_start = 1
  month_stop = 12
  faetureMatrix = []
  for doc in data
    doc.company.size = check_company_scale(doc.company.size)
    doc.title = check_title(doc.title,titles)
    doc.endDate = Math.round(Date(doc.endDate?.year,doc.endData?.month).getTime / 1000)
    doc.startDate = Math.round(Date(doc[4].startDate?.year,doc[4].startDate?.month).getTime / 1000)
    doc.elapsedTime = if doc.endData > 0 then doc.endDate - doc.startDate else null
    featureVector = []
    for year in [year_start..year_stop]
      for month in [month_start..month_stop]
        featureVector.push compute_influence doc, Math.round(Date(year,month).getTime / 1000)
    doc.featureVector = featureVector
    featureMatrix.push doc
  return featureMatrix
 
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
  for sorted_item in scale_with_index
    data[sorted_item[1]].distance = sorted_item[0]
    data[sorted_item[1]].rank = sorted_item[1]
  topSimilarUsers = (data[sorted_item[1]] for sorted_item in scale_with_index)[0:k]
  return topSimilarUsers

position_proposal = (sample, candidates, length_suggestions) ->
  presentPoint = (position.endDate for position in sample).max (array) -> 
    Math.max.apply Math,array
  presentPoint = Date(presentPoint * 1000)
  presentYear = presentPoint.getYear()
  presentMonth = presentPoint.getMonth()
  presentIndex = presentYear - 2005 + presentMonth
  user_average = sample.featureVector.reduce (c,i) -> c += i
  user_average = user_average / sample.length
  recommendations = []
  normalizationConstant = (candidate.distance for candidate in candidates).reduce (c,i) -> c += i
  for index in [presentIndex..presentIndex+length_suggestions]
    weight = (candidate.weight * ( candidate.featureVector[presentIndex] - user_average )  for candidate in candidates).reduce (c,i) -> c += i
    recommendedScore = user_average + weight / normalizationConstant
    recommendations.push recommendedScore
  return recommendations

collaborative_filtering = (test_sample, train_samples, k, dist_func) -> 
  distances = ( dist_func( test_sample.featureVector, train_sample.featureVector ) for train_sample in train_samples )
  topSimilarUsers = fetch_top_samples(train_samples, distances, k)
  recommendedPosition = position_proposal(test_sample, topSimilarUsers, k)
  return recommendedPosition

recommend = (user,k = 2) ->
  k = 5 if k > 5
  # Here comes the recommendation/prediction
  user = [user] if user instanceof Array
  positions = get_user_data()
  features = normalize_feature(positions)
  userFeature = normalize_features(user)
  recommendation = collaborative_filtering(userFeature,features,k,cosine_similarity)
  return recommendation
