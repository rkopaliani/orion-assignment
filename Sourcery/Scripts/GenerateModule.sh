while getopts n:o: flag
do
    case "${flag}" in
        n) modulename=${OPTARG};;
        o) outputpath=${OPTARG};;
    esac
done
echo "Module name: $modulename";
echo "Output path: $outputpath";

tempdirpath="$outputpath/$modulename/Temp"
temprootfile="$tempdirpath/Root.swift"

if [ ! -d "$outputpath/$modulename" ] 
then
    mkdir -p $outputpath/$modulename
fi

if [ ! -d "$tempdirpath" ] 
then
    mkdir -p $tempdirpath
fi

if [ -f "$tempdirpath/Root.swift" ]; then
    echo "File $tempdirpath/Root.swift already exists"
    exit 2
fi

if [ -f "$tempdirpath/Template.swift" ]; then
    echo "File $tempdirpath/Template.swift already exists"
    exit 2
fi

if [ -f "$tempdirpath/Header.swift" ]; then
    echo "File $tempdirpath/Header.swift already exists"
    exit 2
fi

headerfile="$tempdirpath/Header.swift"

prepare_header_file() {

    echo "//" > $headerfile
    echo "//  $1.swift" >> $headerfile
    echo "//  Frontend" >> $headerfile
    echo "//" >> $headerfile
    echo "//  Created by script on $(date +"%d.%m.%Y")." >> $headerfile
    echo "//  Copyright © $(date +"%Y") orion-assigment. All rights reserved." >> $headerfile
    echo "//\n" >> $headerfile
    cat headerfile
}

templatefile="$tempdirpath/Template.swift"
echo "" > $templatefile
cat templatefile

echo "protocol AutoGeneratable {}" >> $temprootfile
echo "" >> $temprootfile
echo "struct $modulename: AutoGeneratable {}" >> $temprootfile
cat temprootfile

cat "$outputpath/$modulename/$modulename.swift"
sourcery --sources "$tempdirpath" --output "$outputpath/$modulename/$modulename.swift" --templates "../templates/ModuleRootTemplate.stencil"

prepare_header_file "$modulename"
mv $headerfile $templatefile
tail -n +5 "$outputpath/$modulename/$modulename.swift" >> "$templatefile" && mv "$templatefile" "$outputpath/$modulename/$modulename.swift"

cat "$outputpath/$modulename/$modulename+Model.swift"
sourcery --sources "$tempdirpath" --output "$outputpath/$modulename/$modulename+Model.swift" --templates "../templates/Module+ModelTemplate.stencil"

prepare_header_file "$modulename+Model"
mv $headerfile $templatefile
tail -n +5 "$outputpath/$modulename/$modulename+Model.swift" >> "$templatefile" && mv "$templatefile" "$outputpath/$modulename/$modulename+Model.swift"

cat "$outputpath/$modulename/$modulename+Model+Impl.swift"
sourcery --sources "$tempdirpath" --output "$outputpath/$modulename/$modulename+Model+Impl.swift" --templates "../templates/Module+Model+ImplTemplate.stencil"

prepare_header_file "$modulename+Model+Impl"
mv $headerfile $templatefile
tail -n +5 "$outputpath/$modulename/$modulename+Model+Impl.swift" >> "$templatefile" && mv "$templatefile" "$outputpath/$modulename/$modulename+Model+Impl.swift"

cat "$outputpath/$modulename/$modulename+VM.swift"
sourcery --sources "$tempdirpath" --output "$outputpath/$modulename/$modulename+VM.swift" --templates "../templates/Module+VMTemplate.stencil"

prepare_header_file "$modulename+VM"
mv $headerfile $templatefile
tail -n +5 "$outputpath/$modulename/$modulename+VM.swift" >> "$templatefile" && mv "$templatefile" "$outputpath/$modulename/$modulename+VM.swift"

cat "$outputpath/$modulename/$modulename+VM+Impl.swift"
sourcery --sources "$tempdirpath" --output "$outputpath/$modulename/$modulename+VM+Impl.swift" --templates "../templates/Module+VM+ImplTemplate.stencil"

prepare_header_file "$modulename+VM+Impl"
mv $headerfile $templatefile
tail -n +5 "$outputpath/$modulename/$modulename+VM+Impl.swift" >> "$templatefile" && mv "$templatefile" "$outputpath/$modulename/$modulename+VM+Impl.swift"

cat "$outputpath/$modulename/$modulename+View.swift"
sourcery --sources "$tempdirpath" --output "$outputpath/$modulename/$modulename+View.swift" --templates "../templates/Module+ViewTemplate.stencil"

prepare_header_file "$modulename+View"
mv $headerfile $templatefile
tail -n +5 "$outputpath/$modulename/$modulename+View.swift" >> "$templatefile" && mv "$templatefile" "$outputpath/$modulename/$modulename+View.swift"

cat "$outputpath/$modulename/$modulename+Assets.swift"
sourcery --sources "$tempdirpath" --output "$outputpath/$modulename/$modulename+Assets.swift" --templates "../templates/Module+AssetsTemplate.stencil"

prepare_header_file "$modulename+Assets"
mv $headerfile $templatefile
tail -n +5 "$outputpath/$modulename/$modulename+Assets.swift" >> "$templatefile" && mv "$templatefile" "$outputpath/$modulename/$modulename+Assets.swift"

rm -r "$tempdirpath"

