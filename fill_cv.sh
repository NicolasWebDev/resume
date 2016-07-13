#! /bin/bash
# script fill_cv.bash

VIEWER=evince

# description des colonnes dans le fichier de données
ES_COL=2
EN_COL=3
FR_COL=4

print_usage()
{
  echo "Usage: fill_cv <cv_a_remplir> <donnees> <lang_code>"
  echo "<lang_code> : en pour Anglais, es pour Espagnol, fr pour Francais, en minuscules"
}

# on teste qu'il y a bien trois arguments sur la ligne de commande
if [ "$#" -ne 3 ]
then
  print_usage
  exit 1
fi

case $3 in
  en) column=$EN_COL
    ;;
  es) column=$ES_COL
    ;;
  fr) column=$FR_COL
    ;;
  *) print_usage
    exit 2
    ;;
esac

tex_file_in="$1"
data_file="$2"
lang_code="$3"
tex_file_out="$(basename $tex_file_in .tex)_${lang_code}_filled.tex"
pdf_file="$(basename $tex_file_out .tex).pdf"

#set -x
cp $tex_file_in $tex_file_out
while read -r line
do
  # si c'est un commentaire (ie commence par #), on ne fait rien
  if [[ ${line:0:1} != "#" ]]
  then
    tmp_column=$column
    # s'il n'y a qu'un champ, ça veut dire que la traduction est la même pour toute les langues
    #echo $(grep -o "=" <<<$line | wc -l)
    fields_nb=$(grep -o '=' <<<$line | wc -l)
    #echo "fields_nb = $fields_nb"
    if [[ $fields_nb == "1" ]]
    then
      tmp_column=2
    fi

    #echo "tmp_column = $tmp_column"

    variable=$(echo $line | cut -d= -f1)
    # le sed sert a echapper dans la variable valeur les '/' en les remplacant par des '\/', et ce pour la commande sed plus loin
    value="$(echo $line | cut -d= -f$tmp_column | sed 's/\//\\\//g')"
    if [[ $value == "" ]]
    then
      value="MISSING"
    fi
    #echo $variable
    #echo $value
    sed -i "s/$variable/$value/g" $tex_file_out
  fi
done < $data_file

pdflatex $tex_file_out && $VIEWER $pdf_file || echo "UNE ERREUR S'EST PRODUITE DANS LA COMPILATION TEX"
