for curdir in $(ls communities/* -d); do
	mkdir -p "$curdir/images"
done;

for tsv_file in $(ls communities/*/*.tsv | xargs -n1 basename); do
	export TSV=$tsv_file                                           #4ch_-95355317_20220512_180137.tsv
	export DIR="${TSV%.ts*}"                                       #4ch_-95355317_20220512_180137
	export NAME_D=`echo $TSV | sed 's/\_-/!-/1' | cut -f1 -d "!"`  #4ch
	export NAME_DIR=`echo $DIR | rev | cut -c 17- | rev`           #4ch_-95355317
	# echo "communities/${NAME_D}/images/"
	cut -f2,9 communities/$NAME_D/$TSV | parallel --colsep '\t' -j 10 'wget -q {2} -O "communities/${NAME_D}/images/${NAME_DIR}_{1}.jpg"'
done;
