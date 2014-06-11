#!/bin/bash

# YouTube Downloader (powered by YouTube-dl)
# Script Written by Calvin Barrie (viperfan91)

# Define CL input
myTubeURL=$1
#mediaType=$2

# Create arrays that contain possible quality options
# Arrays are ordered so that the highest possible options are tried frist
# itag values from http://en.wikipedia.org/wiki/YouTube#Quality_and_codecs
audioOptions=("141" "140" "139")
videoOptions=("264" "137" "136" "135" "134" "133" "160")

#Miscellaneous Variables

#--------------------------------------------------
# Begin code for downloading the audio from YouTube
#--------------------------------------------------

# Remove the '#' for lines " :<<'END' " & " END " to script downloading the file from YouTube
# and only handle filesystem arguments 

#: <<'END'
success=1
i=0
until [ $success == 0 ]; do
	theAttempt=$(youtube-dl -q -f ${audioOptions[$i]} $myTubeURL > /dev/null 2>&1; echo $?)
	#echo $theAttempt
	if [ $theAttempt == 0 ] 
	then
	success=$theAttempt
	else
	i=$i+1
	fi
done
#END

#--------------------------------------------------
# Begin code for downloading the video from YouTube
#--------------------------------------------------

#: <<'END'
success=1
i=0
until [ $success == 0 ]; do
	theAttempt=$(youtube-dl -q -f ${videoOptions[$i]} $myTubeURL > /dev/null 2>&1; echo $?)
	#echo $theAttempt
	if [ $theAttempt == 0 ] 
	then
	success=$theAttempt
	else
	i=$i+1
	fi
done
#END

#-----------------------------------------
# Begin code for handling downloaded files
#-----------------------------------------

tubeAudioFile=$(echo $(youtube-dl -e $myTubeURL)"-"$(youtube-dl --get-id $myTubeURL)".m4a")

tubeVideoFile=$(echo $(youtube-dl -e $myTubeURL)"-"$(youtube-dl --get-id $myTubeURL)".mp4")
convertedFileName=$(echo $(youtube-dl -e $myTubeURL)".mp4")

ffmpeg -i "$tubeAudioFile" -i "$tubeVideoFile" "$convertedFileName"

rm "$tubeAudioFile"
rm "$tubeVideoFile"