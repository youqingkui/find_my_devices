exports.getLocalTime = (nS) ->
  year = new Date(parseInt(nS) * 1000).getFullYear();
  month = new Date(parseInt(nS) * 1000).getMonth() + 1;
  if month < 10
    month = '0' + month
  day = new Date(parseInt(nS) * 1000).getDate();
  if day < 10
    day = '0' + day
  time = year + '-' + month + '-' + day
  return time;

exports.loadJSON = (data) ->
  try
    res = JSON.parse(data)
  catch

