#Create Temp Folder If It Does Not Exist
$temp = 'C:\temp\d3'
if (Test-Path -Path $temp) {
    "Path exists!"
} else {
    "Path doesn't exist."
    New-Item -ItemType directory -Path $temp
}

clear-host

#Pulls Latest Patch Version
$webresponse = Invoke-Webrequest -Uri "https://www.d3planner.com/api/versions.php"
$patch = $webresponse.Content -split ","
$patch = $patch | select-string "]}"
$patch = $patch -replace ']}',''



#Remove # In Next Line to Enter Custom Patch Verison
#$patch = read-host "Enter patch version"



#Set Type Of Data To Scrape From D3Planner.com
$type = "1xx_AffixList"

#Remove # In Next Line to Enter Custom Data Type
#$type = read-host "Enter Data Type"



#Hash Function created by TonicBox
Function gbid([string]$str) {
  $hash = 0
  $str = $str.ToLower()
  $array = [char[]]$str
  for ($i=0; $i -lt $array.length; $i++) {
    $hash = ($hash -shl 5) + $hash + [byte][char]$array[$i]
    while($hash -gt 2147483647) {
        $hash -= 4294967296
    }
    while($hash -lt -2147483648) {
        $hash += 4294967296
    }
  }
  #echo is to see if data is formatted correctly
  echo "$hash`t=`t$str`t=`t$type"
  Add-Content C:\Temp\$patch'_'$type'Final'.txt "$hash`t=`t$str`t=`t$type"
}


#Removed any existing file as this script will append to existing file. Remove next line if you want to append data.
Remove-Item -Path C:\Temp\$patch'_'$type'Final'.txt -Force


#Scrape page and convert to readable list.
$WebResponseItem = Invoke-WebRequest "https://d3planner.com/api/$patch/raw/$type"
$WebResponseItem.Content | Set-Content -Path C:\temp\d3\$type'Raw'.txt
get-content C:\temp\d3\$type'Raw'.txt | select-string "x000_Text" | Set-Content -Path C:\temp\d3\$type'Name'.txt
((Get-Content -path C:\temp\d3\$type'Name'.txt -Raw) -replace '      "x000_Text": "','') | Set-Content -Path C:\temp\d3\$type'Name'.txt
((Get-Content -path C:\temp\d3\$type'Name'.txt -Raw) -replace '",','') | Set-Content -Path C:\temp\d3\$patch'_'$type.txt
(gc C:\temp\d3\$patch'_'$type.txt) | ? {$_.trim() -ne "" } | set-content C:\temp\d3\$patch'_'$type.txt


#This section parses the data and puts it into editor ready format. This list is not sorted.
foreach($line in Get-Content C:\temp\d3\$patch'_'$type.txt) {
    if($line -match $regex){
        gbid($line)
        }
}

#Remove Temp D3 files
Remove-Item -Path $temp -Force -Recurse

