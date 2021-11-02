#!/bin/bash

# Base URL.
bing="https://www.bing.com"

# API end point.
api="/HPImageArchive.aspx?"

# Response Format (json|xml).
format="&format=js"

random=0

# Get specific wallpaper specefied by number
re='^[0-9]+$'
if [[ $1 =~ $re ]] ; then
    random="$1"
# if it's not specified nor is current get a random one
elif [ "$1" != "c" ]; then
	# Generate a random number between 0-7
	random=$(shuf -i 0-7 -n 1)
fi

echo "$random"

# For day (0=current; 1=yesterday... so on).
day="&idx=$random"

# Market for image.
market="&mkt=en-US"

# API Constant (fetch how many).
const="&n=1"

# Image extension.
extn=".jpg"

# Size.
size="1366x768"

# Collection Path.
Backgrounds_path="$HOME/Pictures/Backgrounds/Bing/"

# mkdir path if not exixst
mkdir -p $Backgrounds_path

# Required Image Uri.
reqImg=$bing$api$format$day$market$const

echo "$reqImg"

# Logging.
echo "Pinging Bing API..."

# Fetching API response.
apiResp=$(curl -s $reqImg)

if [ $? -gt 0 ]; then
	echo "Ping failed!"
	exit 1
fi

# Default image URL in case the required is not available.
defImgURL=$bing$(echo $apiResp | grep -Po "url\":\"[^\"]*" | cut -d "\"" -f 3)

# Req image url (raw).
reqImgURL=$bing$(echo $apiResp | grep -Po "urlbase\":\"[^\"]*" | cut -d "\"" -f 3)"_"$size$extn

# Image copyright.
copyright=$(echo $apiResp | grep -Po "copyright\":\"[^\"]*" | cut -d "\"" -f 3)

# Checking if reqImgURL exists.
if ! wget --quiet --spider --max-redirect 0 $reqImgURL; then
	reqImgURL=$defImgURL
fi

# Logging.
echo "Bing Image of the day: $reqImgURL"

# Getting Image Name.
imgName=${reqImgURL##*/}

# Saving Image to collection.
wget -ct0 -O "$Backgroundspath$imgName" "$reqImgURL"

# Logging.
echo "Saving image to $Backgrounds_path$imgName"

echo "$copyright" > "$Backgrounds_path${imgName/%.jpg/.txt}"
# Writing copyright.

nitrogen --set-auto "$Backgrounds_path$imgName"
