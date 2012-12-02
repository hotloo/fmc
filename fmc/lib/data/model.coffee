
normal = (mean,std) -> ( Math.random() * std ) + mean

normalize_feature = (data) ->
  titles = get_title_data().fetch()[0]
  check_title = (title,example_titles) ->
    if title in example_titles.top
      return 5
    if title in example_titles.senior
      return 4
    if title in example_titles.middle
      return 3
    if title in example_titles.junior
      return 2
    if title in example_titles.low
      return 1
    else
      return 1

  check_company_scale = (company_size) ->
    switch company_size
      when "10,001+ employees"
        return 5
      when "5001-10000 employees"
        return 4
      when "1001-5000 employees"
        return 3
      when "201-1000 employees"
        return 2
      when "51-200 employees"
        return 1
      when "11-50 employees"
        return 1
      when "1-10 employees"
        return 1
      else return 1

  compute_influence = (positions, current_time) ->
    return if positions.length == 0
    influence = []
    for position in positions
      if position.startDate < current_time < position.endDate
        influence.push ( position.title / 5 ) * (position.company_size / 5)
      else
        influence.push 0.0
    average_influence = influence.reduce (c,i) -> c += i 
    average_influence = average_influence / influence.length
    return average_influence

  year_start = 2000
  year_stop = 2013
  month_start = 1
  month_stop = 12
  featureMatrix = []
  for doc in data
    for subdoc in doc
      subdoc.company_size = check_company_scale(subdoc.company.size)
      subdoc.title = check_title(subdoc.title,titles)
      try
        subdoc.endDate = Math.round((new Date(subdoc.endDate.year,subdoc.endData.month)).getTime() / 1000) if subdoc.endDate
      catch error
        subdoc.endDate = Math.round((new Date(subdoc.endDate.year,12)).getTime() / 1000) if subdoc.endDate
      unless subdoc.endDate
        subdoc.endDate = Math.round((new Date(2013,1)).getTime() / 1000)
      try
        subdoc.startDate = Math.round((new Date(subdoc.startDate.year,subdoc.startDate.month)).getTime() / 1000) if subdoc.startDate
      catch error
        subdoc.startDate = Math.round((new Date(subdoc.startDate.year,12)).getTime() / 1000) if subdoc.startDate
      subdoc.elapsedTime = subdoc.endDate - subdoc.startDate
    featureVector = []
    for year in [year_start..year_stop]
      for month in [month_start..month_stop]
        featureVector.push compute_influence( doc, Math.round((new Date(year,month)).getTime() / 1000) )
    temp = {}
    temp.featureVector = featureVector
    temp.doc = doc
    featureMatrix.push temp
  return featureMatrix

  
interpretTitle = (positionScore,mean,std) ->
  console.log positionScore,mean,std
  positionScore = positionScore * std + mean
  company_score = title_score = Math.ceil(Math.sqrt(positionScore * 5))
  console.log company_score, title_score
  if company_score is 5
    company_size = "10,001+ employees"
  if company_score is 4
    company_size = "5001-10000 employess"
  if company_score is 3
    company_size = "1001-5000 employess"
  if company_score is 2
    company_size = "201-1000 employess"
  if company_score is 1
    company_size = "51-200 employess"
  if company_score is 1
    company_size = "11-50 employess"
  if company_score is 1
    company_size = "1-10 employess"
  else
    company_size = "Seems tricky size"
  
  titles = get_title_data().fetch()[0]

  if title_score is 5
    randI = Math.floor( Math.random() * titles.top.length )
    title = titles.top[randI]
  if title_score is 4
    randI = Math.floor( Math.random() * titles.senior.length )
    title = titles.senior[randI]
  if title_score is 3
    randI = Math.floor( Math.random() * titles.middle.length )
    title = titles.middle[randI]
  if title_score is 2
    randI = Math.floor( Math.random() * titles.junior.length )
    title = titles.junior[randI]
  if title_score is 1
    randI = Math.floor( Math.random() * titles.low.length )
    title = titles.low[randI]
  else
    randI = Math.floor( Math.random() * titles.low.length )
    title = titles.low[randI]
  info = {}
  info.name = title
  info.size = company_size
  return info
 
cosine_similarity = (sample_1, sample_2) ->
  nominator = (sample_i * sample_2[i] for sample_i, i in sample_1).reduce (a,b) -> a + b
  denominator_sample_1 = (sample_i * sample_i for sample_i in sample_1).reduce (a,b) -> a + b
  denominator_sample_1 = Math.sqrt(denominator_sample_1)
  denominator_sample_2 = (sample_i * sample_i for sample_i in sample_2).reduce (a,b) -> a + b
  denominator_sample_2 = Math.sqrt(denominator_sample_2)
  if denominator_sample_1 is 0.0 or denominator_sample_2 is 0.0 then 0.0 else nominator / ( denominator_sample_1 * denominator_sample_2 )

fetch_top_samples = (data,scale,k) ->
  scale_with_index = ([scale_point,i] for scale_point,i in scale)
  scale_with_index.sort (left,right) ->
    if left[0] < right[0] then -1 else 1
  for sorted_item in scale_with_index
    data[sorted_item[1]].distance = sorted_item[0]
    data[sorted_item[1]].rank = sorted_item[1]
  topSimilarUsers = (data[sorted_item[1]] for sorted_item in scale_with_index)
  top = topSimilarUsers[0..k]
  return top

position_proposal = (sample, candidates, length_suggestions) ->
  presentPoint = ( parseInt( position.endDate ) for position in sample.doc )
  presentPoint = Math.max presentPoint...
  presentPoint = new Date(presentPoint * 1000)
  presentYear = presentPoint.getFullYear()
  presentMonth = presentPoint.getMonth()
  presentIndex = (presentYear - 2000) * 12.0 + presentMonth + 1
  user_average = sample.featureVector.reduce (c,i) -> c += i
  user_average = user_average / sample.featureVector.length
  recommendations = []
  normalizationConstant = (candidate.distance for candidate in candidates).reduce (c,i) -> c += i
  for index in [presentIndex..presentIndex+length_suggestions]
    weight = (candidate.distance * ( candidate.featureVector[presentIndex] - user_average )  for candidate in candidates).reduce (c,i) -> c += i
    recommendedScore = user_average + ( weight / normalizationConstant )    
    recommendations.push recommendedScore
  return recommendations

position_length = (sample, candidates, length_suggestions) ->
  presentPoint = ( parseInt( position.endDate ) for position in sample.doc )
  presentPoint = Math.max presentPoint...
  presentPoint = new Date(presentPoint * 1000)
  presentYear = presentPoint.getFullYear()
  presentMonth = presentPoint.getMonth()
  presentIndex = (presentYear - 2000) * 12.0 + presentMonth
  mu_list = []
  for candidate in candidates
    mu_list.push (can_doc.elapsedTime for can_doc in candidate.doc)...
  mu_list = mu_list.filter (mu)-> not isNaN(mu)
  mu = mu_list.reduce (c,i) -> c += 1
  mu_sample_list = (position.elapsedTime for position in sample.doc).filter (mu) -> not isNaN(mu)
  mu = mu + mu_sample_list.reduce (c,i) -> c+= i
  mu = mu / ( mu_list.length + mu_sample_list.length )
  sigma = ( (num - mu) * (num - mu) for num in mu_list).reduce (c,i) -> c += i
  sigma = sigma + ( (num - mu) * (num - mu) for num in mu_sample_list).reduce (c,i) -> c += i
  sigma = sigma / ( mu_list.length + mu_sample_list.length - 1)  
  std = Math.sqrt(sigma)
  length = []
  for i in [0..length_suggestions]
    length.push normal(mu,std)
  work_time = []
  presentPoint = ( parseInt( position.endDate ) for position in sample.doc )
  presentPoint = Math.max presentPoint...
  for i in [0..length_suggestions]
    if i is 0
      work_time_temp = {}
      work_time_temp.startDate = presentPoint + 1
      work_time_temp.stopDate = presentPoint + length[i]
      work_time.push work_time_temp
      continue
    work_time_temp = {}
    work_time_temp.startDate = work_time[i-1].stopDate + 1
    work_time_temp.stopDate = work_time[i-1].stopDate + length[i]
    work_time.push work_time_temp
    
  return work_time
  
collaborative_filtering = (test_sample, train_samples, k, dist_func) -> 
  distances = ( dist_func( test_sample.featureVector, train_sample.featureVector ) for train_sample in train_samples )
  topSimilarUsers = fetch_top_samples(train_samples, distances, k)
  recommendedPosition = position_proposal(test_sample, topSimilarUsers, k)
  recommendedTimes = position_length(test_sample, topSimilarUsers, k)
  return [recommendedPosition,recommendedTimes]

recommend = (user,k = 2) ->
  k = 5 if k > 5
  # Here comes the recommendation/prediction
  user = [user] unless user[0] instanceof Array
  positions = get_user_positions()
  features = normalize_feature(positions)
  for feature,index in features
    mean = feature.featureVector.reduce (c,i) -> c += i
    mean = mean / feature.featureVector.length
    sigma = ( (featureVectorIndex - mean) * (featureVectorIndex - mean) for featureVectorIndex in feature.featureVector).reduce (c,i) -> c += i
    std = Math.sqrt( sigma / (feature.featureVector.length - 1 ) )
    features[index].normalizedFeatures = ( (feature.featureVectorIndex - mean) / std for featureVectorIndex in feature.featureVector)
  userFeatures = normalize_feature(user)
  for userFeature,index in userFeatures
    userFeatures[index].normalizedFeatures = ( (feature.featureVectorIndex - mean) / std for featureVectorIndex in userFeature.featureVector)
  recommendations = []
  for userFeature in userFeatures
    [recommendedPosition,recommendedTimes] = collaborative_filtering(userFeature,features,k,cosine_similarity)
    for i in [0..k]
      recommendation = {}
      recommendation.title = interpretTitle(recommendedPosition[i],mean,std)
      recommendation.time = recommendedTimes[i]
#      console.log recommendation
      recommendations.push recommendation
  return recommendations
