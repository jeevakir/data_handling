#please ensure that the folders are of depth 1. subdirectories in path will messup the script
infolder='tos_Oday/'
outfolder='tos_6hr/'
tfolder='first_last_timestep/'
doutfolder='decade-out/'

echo""
mkdir -p $tfolder $outfolder $doutfolder

read -p "do you want to interpolate the files to 6hr (skip if already done) type yes to continue: "  answer

if [[ "$answer" != "yes" ]]; then
	echo "skipping to next stage"
else
	# interpolate to 6-hourly files
	for x in ${infolder}tos_Oday*.nc
	do
	outprefix=`echo $x | cut -d/ -f2 | cut -d_ -f1`'_6hr_'`echo $x | cut -d/ -f2 |cut -d_ -f3-6`
	syear=`echo $x | grep -oE '[0-9]{8}-[0-9]{8}' | cut -c1-8`
	eyear=`echo $x | grep -oE '[0-9]{8}-[0-9]{8}' | cut -c10-17`
	outfile=$outfolder$outprefix'_'$syear'1200'-$eyear'1200.nc'
	echo $outfile
	cdo -intntime,4 $x $outfile
	done
fi

echo ""
#prompt for next part 
read -p "files are interpolated to the folder ${outfolder} type yes to continue split/shift time: "  answer

if [[ "$answer" != "yes" ]]; then
	echo "skipping to next stage"
	#exit 1
else
	# split timestamps and shift it to missing timestamps 
	# later they are merged to get uniform format with other files

	infilepattern=${outfolder}tos_6hr*.nc
	
	for infile in ${infilepattern} 
	do
	fdate00=`echo $infile | grep -oE '[0-9]{12}-[0-9]{12}' | cut -c1-8`'0000'
	fdate06=`echo $infile | grep -oE '[0-9]{12}-[0-9]{12}' | cut -c1-8`'0600'
	ldate=`echo $infile | grep -oE '[0-9]{12}-[0-9]{12}' | cut -c14-21`'1800'
	nyr=`echo $infile | grep -oE '[0-9]{12}-[0-9]{12}' | cut -c14-17`
	nyrdate=$((nyr+1))'01010000'

#output file names
	fdate06outf=$tfolder$fdate06".nc"
	ldateoutf=$tfolder$ldate".nc"
	nyrdateoutf=$tfolder$nyrdate".nc"


#cdo copy first and last timesteps to shift to missing timesteps

	cdo -seltimestep,1 $infile fdatetmp.nc
	cdo -seltimestep,-1 $infile ldatetmp.nc
	sleep 1
	cdo shifttime,-6hours fdatetmp.nc $fdate06outf
	sleep 1
	cdo shifttime,6hours ldatetmp.nc $ldateoutf
	sleep 1
	cdo shifttime,12hours ldatetmp.nc $nyrdateoutf
	rm -f fdatetmp.nc ldatetmp.nc
	done
fi

# next part is to merge the created files
echo""
read -p "Are you sure want to merge the shifted time files into main decadal file? type yes to continue: "  answer

if [[ "$answer" != "yes" ]]; then
	echo "Aborting script"
	exit 1
else
	infilepattern=${outfolder}tos_6hr*.nc
	

	for infile in ${infilepattern} 
	do
	file_prefix=`echo $infile | cut -d/ -f2 | cut -d- -f1 | cut -d_ -f1-6`
	fdate00=`echo $infile | grep -oE '[0-9]{12}-[0-9]{12}' | cut -c1-8`'0000'
	fdate06=`echo $infile | grep -oE '[0-9]{12}-[0-9]{12}' | cut -c1-8`'0600'
	ldate=`echo $infile | grep -oE '[0-9]{12}-[0-9]{12}' | cut -c14-21`'1800'
	nyr=`echo $infile | grep -oE '[0-9]{12}-[0-9]{12}' | cut -c14-17`
	nyrdate=$((nyr+1))'01010000'

	#output file names
	fdate00outf=$tfolder$fdate00".nc"
	fdate06outf=$tfolder$fdate06".nc"
	ldateoutf=$tfolder$ldate".nc"
	nyrdateoutf=$tfolder$nyrdate".nc"
		
	outfilenm=${doutfolder}$file_prefix'_'$fdate06'-'$nyrdate'.nc'
	echo $outfilenm
	cdo -L mergetime $fdate06outf $infile $ldateoutf $nyrdateoutf $outfilenm
	#exit 1
	sleep 3
	done
fi
