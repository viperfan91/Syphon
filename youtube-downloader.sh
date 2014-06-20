#!/bin/bash
# YouTube Downloader (powered by YouTube-dl)
# Script Written by Calvin Barrie (viperfan91)
echo
echo "Initializing..."
# Define CL input
saveMediaType=$1
myTubeURL=$2
#--------------------------------------------------------------------------------------------------------------------------------
#********************************************************************************************************************************
#--------------------------------------------------------------------------------------------------------------------------------
# Check to see if youtube-dl is installed.
# If it is not then ask if the user wants to install it.
youtubedlInstalled=$(youtube-dl -h > /dev/null 2>&1; echo $?)
if [ "$youtubedlInstalled" != "1" ]; then
	if [ "$youtubedlInstalled" != "0" ]; then
	youtubedlInstalled="1"
	fi
fi
ffmpegInstalled=$(ffmpeg -h > /dev/null 2>&1; echo $?)
if [ "$ffmpegInstalled" != 1 ]; then
	if [ "$ffmpegInstalled" != 0 ]; then
	ffmpegInstalled="1"
	fi
fi
whichAreInstalled="$youtubedlInstalled""$ffmpegInstalled"
# Declare install functions
function installDL {
		# Install youtube-dl
		echo "You will be asked for your password multiple times during installation."
		echo
		sleep 3
		echo "Downloading youtube-dl..."
		#generate latest youtube-dl download URL
		baseURL=$(curl -s https://yt-dl.org/downloads/latest)
		newURL=${baseURL##<!*f\=\"}
		newerURL=${newURL%%\">*l>}
		progURL=$(echo $newerURL'/youtube-dl')
		# Use generated URL and store wether it was successful
		usrLOCALcheck=$(cd /usr/local/bin > /dev/null 2>&1; echo $?)
		if [ "$usrLOCALcheck" == "1" ]; then
			sudo mkdir -p /usr/local/bin
		fi
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
}
function installFFmpeg {
	# Install FFmpeg
	echo
	echo "To install FFmpeg please follow the instructions on the official FFmpeg website."
	echo "Would you like to open the download page for FFmpeg? [ (y)es, (n)o ]"
	read openFFmpegSite
	if [ "$openFFmpegSite" == "y" ]; then
		open "http://www.ffmpeg.org/download.html"
	fi
	echo
	echo "Please install FFmpeg and then run this script again."
	echo
	exit
}
if [ "$whichAreInstalled" == "11" ]; then
	echo
	echo "Looks like you have youtube-dl nor FFmpeg installed."
	echo "Both are required to run this script."
	echo "Would you like to install (y)outube-dl, (f)fmpeg, or (b)oth?"
	read installWhich
	if [ "$installWhich" == "y" ]; then
		echo
		echo "Although this script will continue without FFmpeg, the downloaded file(s) may not play."
		echo "Also, if both audio and video are downloaded the files will need to be combined."
		echo "To avoid this check please add 'F' without quotes to the media type option. Ex: -aF or -avF"
		echo
		echo "You're download will begin shortly..."
		sleep 20
		installDL
	elif [ "$installWhich" == "f" ]; then
		installFFmpeg
	elif [ "$installWhich" == "b" ]; then
		installDL
		installFFmpeg
	fi
elif [ "$whichAreInstalled" == "10" ]; then
	echo
	echo "Looks like you do not have youtube-dl installed."
	echo "It is required to run this script."
	echo "Would you like to install it? (y)es or (n)o"
	read installTube
	if [ "$installTube" == "y" ]; then
		installDL
	elif [ "$installTube" == "n" ]; then
		echo
		echo "Have a nice day :)"
		exit
	fi
elif [ "$whichAreInstalled" == "01" ]; then
	skipFFCheck=`echo $saveMediaType|awk '{print match($0,"F")}'`;
	if [ $skipFFCheck -gt 0 ];then
    	echo "Skipping FFmpeg Check"
	else
		echo
		echo "Looks like you do not have FFmpeg installed."
		echo "Although it is not required to run this script it is highly suggested."
		echo "FFmpeg is used after the download process to convert the file(s) into something usable."
		echo "Would you like to install it? (y)es or (n)o"
		read installFF
		if [ "$installFF" == "y" ]; then
			installFFmpeg
		elif [ "$installFF" == "n" ]; then
			echo
			echo "Although this script will continue the downloaded file(s) may not play."
			echo "Also, if both audio and video are downloaded the files will need to be combined."
			echo "To avoid this check please add 'F' without quotes to the media type option. Ex: -aF or -avF"
			echo "You're download will begin shortly..."
			echo
			echo
			sleep 20
		fi
	fi
fi
#--------------------------------------------------------------------------------------------------------------------------------
#********************************************************************************************************************************
#--------------------------------------------------------------------------------------------------------------------------------
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
#--------------------------------------------------------------------------------------------------------------------------------
#********************************************************************************************************************************
#--------------------------------------------------------------------------------------------------------------------------------
# Grab the complete list of available qualities. Also, Serves as a check for the videos availability.
#----------------------------------------------------------------------------------------------------
qualityCheck=$(youtube-dl -F $myTubeURL)
#--------------------------------------------------------------------------------------------------------------------------------
#********************************************************************************************************************************
#--------------------------------------------------------------------------------------------------------------------------------
# Begin code for downloading the audio from YouTube
#--------------------------------------------------
getAudio=$(echo $saveMediaType|awk '{print match($0, "a")}')
if [[ "$getAudio" != "0" ]]; then
echo "Finding best audio..."
success=1
i=0
until [ $success == 0 ]; do
	if echo "$qualityCheck" | grep -q ${audioOptions[$i]}; then
    	#echo "matched";
    	success="0"
	else
    	#echo "no match";
    	i=$i+1
	fi
done
youtube-dl -q -f ${audioOptions[$i]} $myTubeURL > /dev/null 2>&1; echo $?
fi
#--------------------------------------------------------------------------------------------------------------------------------
#********************************************************************************************************************************
#--------------------------------------------------------------------------------------------------------------------------------
# Begin code for downloading the video from YouTube
#--------------------------------------------------
getVideo=$(echo $saveMediaType|awk '{print match($0,"v")}')
if [[ "$getVideo" != "0" ]]; then
echo "Finding best video..."
success=1
i=0
until [ $success == 0 ]; do
	if echo "$qualityCheck" | grep -q ${audioOptions[$i]}; then
    	#echo "matched";
    	success="0"
	else
    	#echo "no match";
    	i=$i+1
	fi
done
youtube-dl -q -f ${audioOptions[$i]} $myTubeURL > /dev/null 2>&1; echo $?
fi
#--------------------------------------------------------------------------------------------------------------------------------
#********************************************************************************************************************************
#--------------------------------------------------------------------------------------------------------------------------------
# Begin code for handling downloaded files
#-----------------------------------------
if [ "$ffmpegInstalled" == "0" ]; then
# Check if anything was downloaded
if [[ $success == 0 ]]; then
	# Declare the variable for the files that have been downloaded.
	echo "Managing file(s)..."
	if [[ "$getAudio" != "0" ]]; then
		tubeAudioFile=$(echo $(youtube-dl -e $myTubeURL)"-"$(youtube-dl --get-id $myTubeURL)".m4a")
	fi
	if [[ "$getVideo" != "0" ]]; then
		tubeVideoFile=$(echo $(youtube-dl -e $myTubeURL)"-"$(youtube-dl --get-id $myTubeURL)".mp4")
	fi
	
	# Convert downloaded file(s) into something usable
	echo "Converting..."
	if [[ "$getAudio" != "0" ]]; then
		convertedFileName=$(echo $(youtube-dl -e $myTubeURL)".m4a")
		ffmpeg -loglevel quiet -i "$tubeAudioFile" "$convertedFileName"
		echo "Cleaning up the mess I've made..."
		rm "$tubeAudioFile"
	elif [[ "$getVideo" != "0" ]]; then
		convertedFileName=$(echo $(youtube-dl -e $myTubeURL)".mp4")
		ffmpeg -loglevel quiet -i "$tubeVideoFile" "$convertedFileName"
		echo "Cleaning up the mess I've made..."
		rm "$tubeVideoFile"
	elif [ "$getAudio" != "0" ] && [ "$getVideo" != "0" ]; then
		convertedFileName=$(echo $(youtube-dl -e $myTubeURL)".mp4")
		ffmpeg -loglevel quiet -i "$tubeAudioFile" -i "$tubeVideoFile" "$convertedFileName"
		echo "Cleaning up the mess I've made..."
		rm "$tubeAudioFile"
		rm "$tubeVideoFile"
	fi
fi
fi