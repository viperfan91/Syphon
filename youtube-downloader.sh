#!/bin/bash

# YouTube Downloader (powered by YouTube-dl)
# Script Written by Calvin Barrie (viperfan91)

echo
echo "Initializing..."

# Check to see if youtube-dl is installed.
# If it is not then ask if the user wants to install it.
checkIfInstalled=$(youtube-dl -h > /dev/null 2>&1; echo $?)

# if not installed
if [ "$checkIfInstalled" != "0" ]; then
	echo
	echo "You do not have youtube-dl installed. It is required for this script."
	echo "Would you like to install it now? (y/n)"
	read installAnswer
	echo
	# Work with user's response
	if [ "$installAnswer" == "y" ]; then
		# User said yes
		echo "You will be asked for your password twice during installation."
		echo
		sleep 3
		echo "Downloading youtube-dl..."
		#generate latest youtube-dl download URL
		baseURL=$(curl -s https://yt-dl.org/downloads/latest)
		newURL=${baseURL##<!*f\=\"}
		newerURL=${newURL%%\">*l>}
		progURL=$(echo $newerURL'/youtube-dl')
		# Use generated URL and store wether it was successful
		downloadAttempt=$(sudo curl $progURL -o /usr/local/bin/youtube-dl > /dev/null 2>&1; echo $?)
		if [ "$downloadAttempt" != "0" ]; then
			# Command came back something other than '0' which means something went wrong
			# Prompt user with the command to download youtube-dl manually to see what goes wrong
			echo
			echo "Something went wrong."
			echo "Please install youtube-dl manually with these two commands:"
			echo
			echo "sudo curl $progURL -o /usr/local/bin/youtube-dl"
			echo
			exit
		else
			# Download worked
			# Now it's time to make the downloaded file usable
			echo "Installing..."
			installAttempt=$(sudo chmod a+x /usr/local/bin/youtube-dl > /dev/null 2>&1; echo $?)
			sleep 3
		fi
	elif [ "$installAnswer" == "n" ]; then
	# User answered no to "Would you like to install it now? (y/n)"
	echo "I'm sorry to see you go."
	exit
	fi
fi

# Define CL input
saveMediaType=$1
myTubeURL=$2

# Create arrays that contain possible quality options
# Arrays are ordered so that the highest possible options are tried frist
# itag values from http://en.wikipedia.org/wiki/YouTube#Quality_and_codecs
audioOptions=("141" "140" "139")
videoOptions=("264" "137" "136" "135" "134" "133" "160")

# Double check input variables
if [[ "$saveMediaType" != "-"* ]] || [[  "$myTubeURL" != *"youtube.com"* ]]; then
	echo "Usage: youtube-downloader [media type: -a, -v, -av] [YouTube URL]"
	exit
fi

#--------------------------------------------------
# Begin code for downloading the audio from YouTube
#--------------------------------------------------

if [[ $saveMediaType == "-a" ]] || [[ $saveMediaType == "-av" ]]; then

echo "Finding best audio..."
# Remove the '#' for lines " :<<'END' " & " END " to stop downloading the file from YouTube
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
	echo "Successfully downloaded audio! :)"
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
echo "Finding best video..."
#: <<'END'
success=1
i=0
until [ $success == 0 ]; do
	theAttempt=$(youtube-dl -q -f ${videoOptions[$i]} $myTubeURL > /dev/null 2>&1; echo $?)
	#echo $theAttempt
	if [ $theAttempt == 0 ] 
	then
	success=$theAttempt
	echo "Successfully downloaded video! :)"
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
	echo "Managing file(s)..."
	if [[ $saveMediaType == "-a" ]]; then
		tubeAudioFile=$(echo $(youtube-dl -e $myTubeURL)"-"$(youtube-dl --get-id $myTubeURL)".m4a")
	elif [[ $saveMediaType == "-v" ]]; then
		tubeVideoFile=$(echo $(youtube-dl -e $myTubeURL)"-"$(youtube-dl --get-id $myTubeURL)".mp4")
	elif [[ $saveMediaType == "-av" ]]; then
		tubeAudioFile=$(echo $(youtube-dl -e $myTubeURL)"-"$(youtube-dl --get-id $myTubeURL)".m4a")
		tubeVideoFile=$(echo $(youtube-dl -e $myTubeURL)"-"$(youtube-dl --get-id $myTubeURL)".mp4")
	fi
	
	# Convert downloaded file(s) into something usable
	echo "Converting..."
	if [[ $saveMediaType == "-a" ]]; then
		convertedFileName=$(echo $(youtube-dl -e $myTubeURL)".m4a")
		ffmpeg -loglevel quiet -i "$tubeAudioFile" "$convertedFileName"
		echo "Cleaning up the mess I've made..."
		rm "$tubeAudioFile"
	elif [[ $saveMediaType == "-v" ]]; then
		convertedFileName=$(echo $(youtube-dl -e $myTubeURL)".mp4")
		ffmpeg -loglevel quiet -i "$tubeVideoFile" "$convertedFileName"
		echo "Cleaning up the mess I've made..."
		rm "$tubeVideoFile"
	elif [[ $saveMediaType == "-av" ]]; then
		convertedFileName=$(echo $(youtube-dl -e $myTubeURL)".mp4")
		ffmpeg -loglevel quiet -i "$tubeAudioFile" -i "$tubeVideoFile" "$convertedFileName"
		echo "Cleaning up the mess I've made..."
		rm "$tubeAudioFile"
		rm "$tubeVideoFile"
	fi
fi