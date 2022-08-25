#keep this script where the list of files are present
$file_list = Get-Content .\Noise_list_45.txt

$infolder = "D:\source\"
$outfolder = $infolder + "noise-out\"

#just a popup to inform steps needed
$wshell = New-Object -ComObject Wscript.Shell
$userinp = $wshell.Popup(" keep this script where the list of files are present;
check the source folder in the script;
To continue with the script click OK, otherwise click Cancel.",0,"WARNING",0x1)
if($userinp -eq 2){Break}


#creating output directory only if it doesnt exist
if (!(Test-Path $outfolder)) {
	New-Item $outfolder -ItemType Directory
}

#copying files to noise-out folder inside the folder with files
foreach ($file in $file_list) {
    $source = $infolder + $file
    Copy-Item $source $outfolder 
}