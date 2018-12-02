#!/bin/sh
# Rotates a video, then trims it.
# This script satisfies my requirements for a specific set of video files. YMMV.
# Example
# Argument $1 is the directory containing the video file to be processed
#    e.g. /home/user1 (no backslash added at end)
# Argument $2 is the prefix of a file which has suffix .mp4,
#    e.g. "something" where the filename is something.mp4
# Argument $3 is the offset in seconds from the start of the video, assumed less than 60
#    e.g. 15 indicates you want the output video to start 15 seconds in from the original
# Argument $4 is the time at which you want to cut the video short, in minute:seconds
#    e.g. 1:45 means end the video at 1:45 into the current video, 0:33 means at 33 seconds.
#    It is used to compute a duration.
# Output file will be in the same folder, and have the name "something-rotate-cut.mp4"
# Example of the full command:
# sh videoproc.sh /home/username 20181130_104020-5-fun-bill 15 1:23
echo "changing to directory $1";

cd "$1"

total="$4"
# if input is 1:06, len is 4.
len=`expr length $4`

# If input is 1:06, then position is "2". This is the 1-based position of the colon.
position=`expr index "$4" :`
# If $4 is 1:06, pm1 would be 1
pm1=`expr $position - 1`;
# If $4 is 1:06, (position - 1) would be 1. If $4 is 24:19, it is 24
minutes=`expr substr $total 1 $pm1`

pp1=`expr $position + 1`;
# If $4 is 1:06, seconds is 06. If $4 is 24:19, it is 19
seconds=`expr substr $total $pp1 $len`

# duration is the total length in seconds.
duration=`expr $minutes \* 60 + $seconds`

# newduration is the total length in seconds minus the offset $3 in seconds
newduration=`expr $duration \- $3`

# minduration is minutes part of duration. secduration is seconds part of duration.
minduration=`expr $newduration \/ 60`
secduration=`expr $newduration \% 60`

lm=`expr length $minduration`
if [ $lm -eq 1 ]
then
	# left pad zero
	minduration=`echo 0$minduration`
fi

lm=`expr length $secduration`
if [ $lm -eq 1 ]
then
	# left pad zero
	secduration=`echo 0$secduration`
fi


# Remarkably, I could not get transpose=1 to work with ffmpeg
# I quit, I'm sticking with avconv for this action.
avconv -i $2.mp4 -strict experimental -vf transpose=1 -codec:a copy $2-transpose.mp4

echo "Rotated file is $2-transpose.mp4";
echo "Duration of new video is 00:$minduration:$secduration";
echo "New video starts at 00:00:$3";
echo "ffmpeg -i $2-transpose.mp4 -ss 00:00:$3 -t 00:$minduration:$secduration $2-rotate-cut.mp4"

ffmpeg -i $2-transpose.mp4 -ss 00:00:$3 -t 00:$minduration:$secduration $2-rotate-cut.mp4