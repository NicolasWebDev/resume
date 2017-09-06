#! /bin/bash
index=1
csvtool -u TAB cat books.csv | tr '\t' ';' | sed 's/&/and/g' | tail -n +2 | while IFS=';' read author date title
do
    year=$(echo $date | cut -d'-' -f1)
    echo book${index}Title=${title}
    echo book${index}Author=${author}
    echo book${index}Date=${year}
    let 'index++'
done

echo
echo

index=$(tail -n +2 books.csv | wc -l)
for index2 in $(seq 1 ${index})
do
    echo "\bookentry{book${index2}Title}{book${index2}Author}{book${index2}Date}"
done
