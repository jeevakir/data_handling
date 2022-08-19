bas="Base"
rc="RCP"
ss="SSP"

for file in **/**/*
do

#looping files

#extract grid number

gd=`echo $file| cut -d_ -f 3 | cut -dd -f 2`
	if [[ ${#gd} == '1' ]]; 
	then
		grd='0'$gd
	else 
		grd=$gd
	fi

#create output folder

fold=`echo $file | cut -d/ -f 1,2`
ofold=out/${fold}
mkdir -p $ofold

#extract location, CMIP version  and scenarios

AR=`echo $file| cut -d_ -f 4 | cut -d. -f 1 | cut -dR -f 2`
loc=`echo $file| cut -d_ -f 2 | cut -c 1`

	if [[ ! $file == *$bas* ]]; 
	then
		scen=`echo $file| cut -d_ -f 1 | cut -d/ -f 3 | cut -c 1,4-`
		if [[ ${#scen} == '3' ]];
		then
			scen2=`echo $scen | cut -dR -f 2`
			scen1=`echo $scen | cut -c 1`
			scen=${scen1}"0"${scen2}
		fi
	else
		scen=`echo $file| cut -d_ -f 1 | cut -d/ -f 3`
	fi


#lati and lon arrays

Slat=(21.75 21.75 21.75 21.75 22 22 22 22.5 22.25 22.25 22.25 22.25 22.5 22.5 22.5 22.5 22.75 22.75 22.75 23 23)
Slon=(88.25 88.5 88.75 89 88.25 88.5 88.75 88.5 88.25 88.5 88.75 89 88.25 88.5 88.75 89 88.5 88.75 89 88.5 88.75)
Alat=(12.5 12.5 12.75 12.75 13 13 13.25 13.25)
Alon=(77.25 77.5 77.25 77.5 77.25 77.5 77.25 77.5)

# Assigning latitiude and logitude from arrays
case $loc in
	A)
	lat=${Alat[$gd-1]}
	long=${Alon[$gd-1]}
	;;
	S)
	lat=${Slat[$gd-1]}
	long=${Slon[$gd-1]}
	;;
esac

#assign out wth file names based on location nd scenarios and AR versions

sc=`echo $scen | cut -c 3`
	case "$AR:$loc:$sc" in
		5:A:s)
			fname=AA${grd}7630.WTH
			INSI=AA
		;;
		5:A:4)
			fname=AB${grd}2140.WTH
			INSI=AB
		;;
		5:A:8)
			fname=AC${grd}2140.WTH
			INSI=AC
		;;
		5:S:s)
			fname=SA${grd}7630.WTH
			INSI=SA
		;;
		5:S:4)
			fname=SB${grd}2140.WTH
			INSI=SB
		;;
		5:S:8)
			fname=SC${grd}2140.WTH
			INSI=SC
		;;
		6:A:s)
			fname=AD${grd}7630.WTH
			INSI=AD
		;;
		6:A:4)
			fname=AE${grd}2140.WTH
			INSI=AE
		;;
		6:A:8)
			fname=AF${grd}2140.WTH
			INSI=AF
		;;
		6:S:s)
			fname=SD${grd}7630.WTH
			INSI=SD
		;;
		6:S:4)
			fname=SE${grd}2140.WTH
			INSI=SE
		;;
		6:S:8)
			fname=SF${grd}2140.WTH
			INSI=SF
		;;
	esac



# replace INSI,lat and lon values in header
awk  -v new="${INSI}${grd}" -v lati=$lat -v lon=$long '(NR==1) {$4=new; {print $1" "$2" "$3" "$4}};		
		      			 	(NR>1 && NR<4 || NR==5) {print $0};
						(NR==4) {$1=new;$2=lati;$3=lon; {printf "%6s%9.3f%9.3f%6s%6s%6s%6s%6s\n",$1,$2,$3,$4,$5,$6,$7,$8}} ' header.txt > tmp.txt

#remove date coloumn and convert SRAD cal/cm2 to MJ/m2
 
awk -F, '($2=$2*0.041) {printf "%6.1f%6.1f%6.1f%6.1f\n",$2,$3,$4,$5}' $file >temp.txt

#join formatted date and values and ouptu wth files

if [[ $file == *$bas* ]];
then		
		paste -d'\0' base_date.txt temp.txt > temp1.txt 
		cat tmp.txt temp1.txt > ${ofold}/${fname}
elif [[ $file == *$rc* ]];
then
	paste -d'\0' RCP_date.txt temp.txt > temp1.txt
	cat tmp.txt temp1.txt > ${ofold}/${fname}
else 
	paste -d'\0' RCP_date.txt temp.txt > temp1.txt 
	cat tmp.txt temp1.txt > ${ofold}/${fname}
fi

# loop end
done
