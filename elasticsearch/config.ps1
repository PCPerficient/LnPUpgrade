$addJavaHome = $true # Allowed values: $true  $false

$clusterName = $null # Allowed values: $null or valid cluster name. If $null then cluster name will be elasticsearch_$hostName
$portNumber = 9201 # default is 9200 but most of our dev machines have 1.X installed and using 9200

#Paths
$jrePath = 'C:\Program Files\Java\jre1.8.0_221' #path to Java Server JRE (relative to script or absolute), point to folder containing bin directory not to bin directory itself
$elasticPath = 'C:\Program Files\elasticsearch'  #path to ElasticSearch (relative to script or absolute), point to folder containing bin directory not to bin directory itself. Relative paths must not start with a \
$elasticVersion = '5.5.3' #the version of elastic search we are using