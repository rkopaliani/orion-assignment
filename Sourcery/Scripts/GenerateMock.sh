while getopts s:o:f: flag
do
    case "${flag}" in
        s) sourcepath=${OPTARG};;
        o) outputpath=${OPTARG};;
        f) filename=${OPTARG};;
    esac
done
echo "Source path: $sourcepath";
echo "Output path: $outputpath";
echo "File name: $filename";

tempdirpath="$outputpath/Temp"

if [ -f "$tempdirpath/Template.swift" ]; then
    echo "File $tempdirpath/Template.swift already exists"
    exit 2
fi

if [ -f "$tempdirpath/Header.swift" ]; then
    echo "File $tempdirpath/Header.swift already exists"
    exit 2
fi

if [ -f "$outputpath/$filename.swift" ]; then
    echo "File $outputpath/$filename.swift already exists"
    exit 2
fi

if [ ! -d "$tempdirpath" ] 
then
    mkdir -p $tempdirpath
fi


headerfile="$tempdirpath/Header.swift"

prepare_header_file() {

    echo "//" > $headerfile
    echo "//  $1.swift" >> $headerfile
    echo "//  FrontendTests" >> $headerfile
    echo "//" >> $headerfile
    echo "//  Created by script on $(date +"%d.%m.%Y")." >> $headerfile
    echo "//  Copyright © $(date +"%Y") orion-assigment. All rights reserved." >> $headerfile
    echo "//\n" >> $headerfile
    cat headerfile
}

templatefile="$tempdirpath/Template.swift"
echo "" > $templatefile
cat templatefile

cat "$outputpath/$filename.swift"
sourcery --sources "$sourcepath" --output "$outputpath/$filename.swift" --templates "../templates/GenerateMockTemplate.stencil"

prepare_header_file "$filename"
mv $headerfile $templatefile
tail -n +5 "$outputpath/$filename.swift" >> "$templatefile" && mv "$templatefile" "$outputpath/$filename.swift"

rm -r "$tempdirpath"

