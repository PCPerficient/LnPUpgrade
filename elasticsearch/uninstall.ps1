. .\config.ps1
try{
    $scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

    if (([System.IO.Path]::IsPathRooted($elasticPath)) -eq $false)
    {

        $elasticPath = (join-path $scriptPath $elasticPath)
    }

    $elasticBinPath = join-path $elasticPath ('\elasticsearch-' + $elasticVersion + '\bin')

    if (Get-Service "Elasticsearch$elasticVersion" -ErrorAction SilentlyContinue)
    {
        cd $elasticBinPath
        ./elasticsearch-service.bat remove "Elasticsearch$elasticVersion"
    }
    else
    {
        Write-Host "Elasticsearch is not installed"
    }
}
finally{
    cd $scriptPath
}