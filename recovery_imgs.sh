for tsv_file in $(ls communities/*/*.tsv | xargs -n1 basename); do

	export TSV=$tsv_file                                          #4ch_-95355317_20220512_180137.tsv
	export DIR="${TSV%.ts*}"                                      #4ch_-95355317_20220512_180137
	export NAME_D=`echo $TSV | sed 's/\_-/!-/1' | cut -f1 -d "!"` #4ch
	export NAME_DIR=`echo $DIR | rev | cut -c 17- | rev`          #4ch_-95355317
	OWNER_ID=$(echo $TSV | rev | cut -f3 -d "_" | rev)            #    -95355317

	echo "Next community ${NAME_D} in process";

	while [ $(find  communities/${NAME_D}/images/ -maxdepth 1 -type f -empty | wc -l) -ne 0 ]; do
		# find communities/${NAME_D}/images/ -maxdepth 1 -type f -empty
		# if [ $NAME_D == "jokesss" ]; then
	 #    	EMPTY_FILES=$(find communities/${NAME_D}/images/ -maxdepth 1 -type f -empty)
		# 	rm $EMPTY_FILES
	 #    	break
		# fi

		COUNT_FILES=$(find communities/${NAME_D}/images/ -maxdepth 1 -type f -empty | wc -l)
		echo "Remain ${COUNT_FILES} empties files"
		
		grep -Ff <(for i in $(find communities/${NAME_D}/images/ -maxdepth 1 -type f -empty | xargs -n1 basename); do \
		echo $i | rev | cut -f1 -d "_" | rev | cut -f1 -d "."; done;) \
		<(cut -f2,9 communities/${NAME_D}/*.tsv) | cut -f1,2 -d $'\t' | \
		parallel --colsep '\t' -j 10 'wget -q {2} -O "communities/${NAME_D}/images/${NAME_DIR}_{1}.jpg"'		

		BAD_FILE=communities/${NAME_D}/images/${NAME_DIR}_id.jpg
		if [ -f "$BAD_FILE" ]; then
	    	rm $BAD_FILE
		fi

	done;	
	# break
done;

