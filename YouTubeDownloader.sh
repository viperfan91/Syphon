#!/bin/bash

# YouTube Downloader (powered by YouTube-dl)
# Script Written by Calvin Barrie (viperfan91)

# Define CL input
saveMediaType=$1
myTubeURL=$2

# Create arrays that contain possible quality options
# Arrays are ordered so that the highest possible options are tried frist
# itag values from http://en.wikipedia.org/wiki/YouTube#Quality_and_codecs
audioOptions=("141" "140" "139")
videoOptions=("264" "137" "136" "135" "134" "133" "160")

# Double check input variables
if [[ $saveMediaType != "-a" ]] || [[ $saveMediaType != "-v" ]] || [[ $saveMediaType != "-av" ]]; then
	echo "Usage: youtube-downloader [media type: -a, -v, -av] [YouTube URL]"
fi

#--------------------------------------------------
# Begin code for downloading the audio from YouTube
#--------------------------------------------------

if [[ $saveMediaType == "-a" ]] || [[ $saveMediaType == "-av" ]]; then

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

fi

#--------------------------------------------------
# Begin code for downloading the video from YouTube
#--------------------------------------------------

if [[ $saveMediaType == "-v" ]] || [[ $saveMediaType == "-av" ]]; then

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

fi

#-----------------------------------------
# Begin code for handling downloaded files
#-----------------------------------------

# Check if anything was downloaded
if [[ $success == 0 ]]; then
	# Declare the variable for the files that have been downloaded.
	if [[ $saveMediaType == "-a" ]]; then
		tubeAudioFile=$(echo $(youtube-dl -e $myTubeURL)"-"$(youtube-dl --get-id $myTubeURL)".m4a")
	elif [[ $saveMediaType == "-v" ]]; then
		tubeVideoFile=$(echo $(youtube-dl -e $myTubeURL)"-"$(youtube-dl --get-id $myTubeURL)".mp4")
	elif [[ $saveMediaType == "-av" ]]; then
		tubeAudioFile=$(echo $(youtube-dl -e $myTubeURL)"-"$(youtube-dl --get-id $myTubeURL)".m4a")
		tubeVideoFile=$(echo $(youtube-dl -e $myTubeURL)"-"$(youtube-dl --get-id $myTubeURL)".mp4")
	fi
	
	# Convert downloaded file(s) into something usable
	if [[ $saveMediaType == "-a" ]]; then
		convertedFileName=$(echo $(youtube-dl -e $myTubeURL)".m4a")
		ffmpeg -i "$tubeAudioFile" -i "$tubeVideoFile" "$convertedFileName"
		rm "$tubeAudioFile"
	elif [[ $saveMediaType == "-v" ]]; then
		convertedFileName=$(echo $(youtube-dl -e $myTubeURL)".mp4")
		ffmpeg -i "$tubeAudioFile" -i "$tubeVideoFile" "$convertedFileName"
		rm "$tubeVideoFile"
	elif [[ $saveMediaType == "-av" ]]; then
		convertedFileName=$(echo $(youtube-dl -e $myTubeURL)".mp4")
		ffmpeg -i "$tubeAudioFile" -i "$tubeVideoFile" "$convertedFileName"
		rm "$tubeAudioFile"
		rm "$tubeVideoFile"
	fi
fi