#! /bin/sh
echo ""

# First internal parameter: Source Directory
# 
# You have to specify the source directory which will contain the images.
SRC_DIR="/Users/darrenkarlsapalo/Downloads/var 2/www/html/media"

# First external parameter: Output file name
#
# Usage:
# ./timelapse-to-video.sh OUTPUT_FILENAME
#
# Notes:
# This will automatically append .mp4 to the file result

OUTPUT_NAME=$1
CURRENT_DIR=$(pwd)

OUTPUT_FILENAME="$CURRENT_DIR/$OUTPUT_NAME.mp4"

if [ "$OUTPUT_NAME" == "" ]; then
    echo "Failed to convert timelapse image into video. Please specify an output filename. Example:"
    echo "   ./timelapse-to-video.sh output_one"
    exit -1
fi

# Validation to check if files exist in the directory.
COUNT_FILES=$(($(ls $SRC_DIR | wc -l)))

if [ $COUNT_FILES -eq 0 ]; then
    echo "There were no files found in specified source directory."
    exit -1
fi

echo "Found a total of $COUNT_FILES files in the source directory."

echo "Preparing filenames for video conversion using ffmpeg."

COUNT_IMAGES=0

# Determines whether the files have been processed already or not.
if [ -f "$SRC_DIR/processed" ]; then 
    echo "Files have already been processed. No need for filename preparation."
else
    for item in "$SRC_DIR"/*
    do
        if [ ${item: -4} == ".jpg" ]; then
            COUNT_IMAGES=$((COUNT_IMAGES+1))
            IFS='_'
            read -ra ARR <<< "$item"
            
            SRC_FILE=$item
            IFS=' '
            
            DEST_FILE="${ARR[0]}_${ARR[2]}.jpg"
            
            # mv "$SRC_FILE" "$DEST_FILE"
            
            # echo $SRC_FILE
            # echo $DEST_FILE
        fi
    done

    if [ $COUNT_IMAGES -eq 0 ]; then
        echo "There were no JPG images found in specified source directory."
        exit -1
    fi

    echo "Prepared $COUNT_IMAGES JPG images for video conversion."

    # Marks as processed
    touch "$SRC_DIR/processed"
fi

echo "Converting timelapse images into video ($OUTPUT_FILENAME)."
ffmpeg -r 25 -i "$SRC_DIR/tl_%4d.jpg" -c:v libx264 -vf fps=25 -pix_fmt yuv420p $OUTPUT_FILENAME