#!/bin/bash
#
# Author: Mathachan Kulathinal
# Date: Friday, 11.Sep.2015
#
# Params pattern for "stream handler" configuration
# <jpeg conversion parameters> <output pdf label> <input dir> <output dir>
#
# Example:
# -density 150 -quality 50% merged_derivative_copy /tmp/images /tmp/output
# -compress JPEG -blur 1x0.5 -quality 92 -resize '900>' pdf_dc /tmp/images /tmp/output
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#
# Location for storing converted jpeg files temporarily
temp_image_dir=/tmp/anz_pdf_deriv_copy_gen
# Location of cover page disclaimer - not used for now
#cover_image_dir=<path>/page-0.jpg

################################################
# Function to set the PATH environment variable
# Affects only this script and does not change the
# environment variable setting otherwise.
################################################
set_paths() {
	# Define the j2kdriver path
	CONVERT_J2K_CMD="j2kdriver"
	# Define ImageMagick path and location
	CONVERT_CMD="<path>/convert"
	# Define the system date command
	DATE_CMD="date"
	# Define sam2p path and location - create pdf tool
	SAM2P_CMD="<path>/sam2p"
	# Define Sejda path and location - merge pdf tool
	SEJDA_CMD="<path>/sejda-console"
}
################################################
# Function to create the directories as
# provided in the parameter list
################################################
create_dir() {
	new_dir=${1}	
	# Create dir if doesn't exist
	if [ ! -d $new_dir ]
	then
		# echo -e "Creating the directory for processing $new_dir \n"
		mkdir -p $new_dir
	fi
	sub_image_dir=$new_dir
}

datetime=`date +%Y%m%d%H%M%S`
create_dir "$temp_image_dir/$datetime"
temp_sip_dir=$sub_image_dir
set_paths

ARGS=""
# wrap all but the three last parameter in brackets (output name, input and output dirs)
for (( i=1;$i<$#-2;i=$i+1 ))
do
  ARGS="$ARGS ${!i}"
done

# Set INPUT/OUTPUT vars
OUTPUT_FILENAME="${!i}"
let i=i+1
INPUT_DIR="${!i}"
let i=i+1
OUTPUT_DIR="${!i}"
OUTPUT_FILE=`echo "$OUTPUT_DIR/$OUTPUT_FILENAME.pdf"`

################################################
# STEP 1: Convert jp2 (JPEG 2000) to temporary
# HIGH-RES jpeg images using j2kdriver
################################################
echo -e "Conversion from jpeg 2000 to high-res jpeg start: `$DATE_CMD`"

# Create first pdf sub-folder
create_dir "$temp_sip_dir"/pdf-step1

j=1
# Process only JPEG 2000 files. Ignore the other file types.
for file in "$INPUT_DIR"/*.jp2
do
	# Call to j2kdriver: accepts J2K file as input; outputs temp jpg file
	if $CONVERT_J2K_CMD -i $file -t jpg -o "$temp_sip_dir"/pdf-step1/page-"$j".jpg
	then
  		echo -e "Converting jp2 image to high-res jpeg image using j2kdriver: $file"
	else
  		echo -e "j2kdriver is unable to perform conversion. Converting jp2 image to high-res jpeg image using ImageMagick: $file"
  		$CONVERT_CMD $file "$temp_sip_dir"/pdf-step1/page-"$j".jpg
	fi
	let j=j+1
done
echo -e "Conversion from jpeg 2000 to high-res jpeg end: `$DATE_CMD`"

################################################
# STEP 2: Convert the temporary JPEG images
# to LOW-RES JPEG images using ImageMagick
################################################
echo -e "Conversion from high-res jpeg to low-res jpeg start: `$DATE_CMD`"

# Create first pdf sub-folder
create_dir "$temp_sip_dir"/pdf-step2

# Copy cover page/Disclaimer page to first pdf sub-folder - not required for now
#cp $cover_image_dir "$temp_sip_dir"/pdf-step2/

for (( i=1;$i<$j;i=$i+1 ))
do
	echo -e "Converting high-res jpeg image to low-res image using ImageMagick: $temp_sip_dir"/pdf-step1/page-"$i".jpg
	$CONVERT_CMD "$temp_sip_dir"/pdf-step1/page-"$i".jpg $ARGS "$temp_sip_dir"/pdf-step2/page-"$i".jpg
done
echo -e "Conversion from high-res jpeg to low-res jpeg end: `$DATE_CMD`"

################################################
# STEP 3: Create temporary PDFs using sam2p
################################################

# PDF generation begin timestamp
echo -e "PDF generation from low-res jpeg images start: `$DATE_CMD`"

# Create sub-folder for PDfs to merge
create_dir "$temp_sip_dir"/pdf-step3

for (( i=1;$i<$j;i=$i+1 ))
do
	# Prepend leading zeros to preserve correct numerically order
	printf -v num '%06d' $i;
	$SAM2P_CMD "$temp_sip_dir"/pdf-step2/page-"$i".jpg "$temp_sip_dir"/pdf-step3/page-"$num".pdf
done

# PDF generation end timestamp
echo "PDF generation from low-res jpeg images end: `$DATE_CMD`"

################################################
# STEP 4: Merge temporary PDFs using sejda
################################################

echo -e "PDF merging from single pdf files start: `$DATE_CMD`"

# Merge jpegs to PDF
$SEJDA_CMD merge -d "$temp_sip_dir"/pdf-step3 -o $OUTPUT_FILE --overwrite

echo -e "PDF merging from single pdf files end: `$DATE_CMD`"

# Delete the temporary files created if any
#echo "Removing the temp directory created for processing $temp_sip_dir"
rm -Rf $temp_sip_dir
