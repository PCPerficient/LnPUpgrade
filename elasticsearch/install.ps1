param (
    [string]$configPath
)

function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  Split-Path $Invocation.MyCommand.Path
}


if ($configPath -eq "") {
    $configPath = Get-ScriptDirectory
}

function Restart-ScriptAsAdmin
{
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() )
    $Invocation=((Get-Variable MyInvocation).value).ScriptName
    if ($Invocation -eq $null -or $currentPrincipal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator ) ){return}
    Start-Process "$psHome\powershell.exe" -Verb Runas -ArgumentList ("-command `"& '"+$Invocation+"'`"")
    break
}

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$numOfSteps = 9

function Install-Elasticsearch {
    . $configPath\config.ps1
    try {
        #------------------------------------
        #Set Paths to absolute if relative paths given
        #------------------------------------
        if (([System.IO.Path]::IsPathRooted($jrePath)) -eq $false)
        {
            $jrePath = (join-path $scriptPath $jrePath)
        }

        if (([System.IO.Path]::IsPathRooted($elasticPath)) -eq $false)
        {
            $elasticPath = (join-path $scriptPath $elasticPath)
        }

        $elasticBinPath = join-path $elasticPath ('\elasticsearch-' + $elasticVersion + '\bin')
        $configPath = join-path $elasticPath  ('\elasticsearch-' + $elasticVersion + '\config\elasticsearch.yml')
        $hostName = [System.Net.Dns]::GetHostName()
        $esAreadyInstalled = $false
        $configOK = $true


        #------------------------------------
        #Validate config
        #------------------------------------
        write-host "Validating config" -foregroundcolor green
        if (-not (test-path $jrePath))
        {
            $configOK = $false
            write-host "    JAVA JRE path doesn't exist: $jrePath"  -foregroundcolor red    -background black
        }

        if (-not (test-path $elasticPath))
        {
            New-Item -ItemType Directory -Force -Path $elasticPath
        }

        if($configOK){
            write-host "    Elasticsearch bin path: $elasticBinPath"  -foregroundcolor gray
            write-host "    JRE path: $jrePath"  -foregroundcolor gray
        }
        else{
            return
        }


        #------------------------------------
        #Download and unzip elastic search
        #------------------------------------
        Write-Host "[1\$numOfSteps] Downloading Elasticsearch" -foregroundcolor green
        $clnt = new-object System.Net.WebClient
        [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
        $url = "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-" + $elasticVersion + ".zip"
        $file = "$elasticPath\elasticsearch-" + $elasticVersion + ".zip"
        $clnt.DownloadFile($url,$file)

        # Unzip the file to specified location
        Write-Host "[2\$numOfSteps] Unzipping Elasticsearch" -foregroundcolor green
        $shell_app=new-object -com shell.application
        $zip_file = $shell_app.namespace($file)
        $destination = $shell_app.namespace($elasticPath)
        $destination.Copyhere($zip_file.items())
        Remove-Item $file


        #------------------------------------
        #Setting JAVA_HOME
        #------------------------------------
        Write-Host "[3\$numOfSteps] Setting JAVA_HOME System Variable" -foregroundcolor green
        if ([environment]::GetEnvironmentVariable("JAVA_HOME","machine") -eq $null -and $addJavaHome)
        {
            [environment]::setenvironmentvariable("JAVA_HOME",$jrePath,"machine")
            $env:JAVA_HOME = $jrePath
        }

        Write-Host "    JAVA_HOME system variable set to: " $jrePath -foregroundcolor gray


        #------------------------------------
        #Setting cluster name
        #------------------------------------
        Write-Host "[4\$numOfSteps] Setting Cluster Name" -foregroundcolor green

        if($clusterName -eq $null)
        {
            $clusterName = "elasticsearch_$hostName"
        }
        (Get-Content $configPath) | ForEach-Object { $_ -replace "#?\s?cluster.name: .+" , "cluster.name: $clusterName" } | Set-Content $configPath
         Write-Host "   Cluster name is: $clusterName"   -foregroundcolor gray


        #------------------------------------
        #Setting port number
        #------------------------------------
        if($portNumber -ne "9200")
        {
            Write-Host "[5\$numOfSteps] Setting Port Number ($portNumber)" -foregroundcolor green
            (Get-Content $configPath) -replace "#?http.port: \d+", "http.port: $portNumber" | Set-Content $configPath
        }
        else
        {
            Write-Host "[5\$numOfSteps] Setting Port Number (default)" -foregroundcolor green
            (Get-Content $configPath) -replace "#?http.port: \d+", "#http.port: 9200" | Set-Content $configPath
        }


        #------------------------------------
        #Install Elasticsearch as a service
        #------------------------------------
        Write-Host "[6\$numOfSteps] Install Elasticsearch As A Service" -foregroundcolor green
        cd $elasticBinPath
        if (-not (Get-Service "Elasticsearch$elasticVersion" -ErrorAction SilentlyContinue) )
        {
            .\elasticsearch-service.bat install "Elasticsearch$elasticVersion"
            Write-Host "    Elasticsearch installed." -foregroundcolor gray
        }
        else
        {
            Write-Host "    Elasticsearch has already been installed." -foregroundcolor gray
            $esAreadyInstalled = $TRUE
        }


        #------------------------------------
        #Start Elasticsearch service
        #------------------------------------
         Write-Host "[7\$numOfSteps] Start Elasticsearch Service" -foregroundcolor green
         Start-Service "Elasticsearch$elasticVersion"
         Write-Host "   Elasticsearch service status: " (service "Elasticsearch$elasticVersion").Status   -foregroundcolor gray

         Write-Host "[8\$numOfSteps] Set Service Startup Type To Automatic" -foregroundcolor green
         set-service "Elasticsearch$elasticVersion" -startuptype automatic
         Write-Host "   Elasticsearch service startup type: " (Get-WmiObject -Class Win32_Service -Property StartMode -Filter "Name='Elasticsearch$elasticVersion'").StartMode  -foregroundcolor gray
         if(-not $esAreadyInstalled ){
             Write-Host "   Waiting 20 seconds for Elasticsearch to start"   -foregroundcolor yellow
             Wait(20)
         }
         Write-Host


        #------------------------------------
        #Sanity check.
        #------------------------------------
         Write-Host "[9\$numOfSteps] Sanity Check. " -foregroundcolor green
         $esRequest = [System.Net.WebRequest]::Create("http://localhost:$portNumber")
         $esRequest.Method = "GET"
         $esResponse = $esRequest.GetResponse()
         $reader = new-object System.IO.StreamReader($esResponse.GetResponseStream())
         Write-Host "   Elasticsearch service response status: " $esResponse.StatusCode   -foregroundcolor gray
         Write-Host "   Elasticsearch service response full text: " $reader.ReadToEnd()   -foregroundcolor gray
         Write-Host


        #------------------------------------
        #Ending notes.
        #------------------------------------
         Write-Host "Elasticsearch Service Endpoint: http://localhost:$portNumber" -foregroundcolor green
         Write-Host
         Write-Host
         Write-Host "Done!" -foregroundcolor green
    }
    finally{
        cd $scriptPath
    }
}

function Wait($seconds)
{
    for ($i=1; $i -le ($seconds*2); $i++)
    {
        $progress = ((($i-1) / ($seconds*2))*100)

        $remaining = [math]::Ceiling($seconds-$i/2)
        Write-Progress -Activity "Waiting $seconds [s]" -status "Remaining time $remaining [s]" -percentComplete $progress

        Start-Sleep -Milliseconds  500
    }
}

Install-Elasticsearch
