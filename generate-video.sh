#!/bin/bash

AUDIO_FILE_PATHS=/usr/sleeptalk/records_to_render/*.wav

echo "Rendering video"
echo ""

debug=false
file_counter=0

for audio_file_path in $AUDIO_FILE_PATHS
do
	if [ -f $audio_file_path ]; then

		audio_file_name=$(basename $audio_file_path)

	 	# todo move to function
		filename=$(echo $audio_file_name | sed "s/\(\.wav\)//")
		sleeptalk_file_path="/usr/sleeptalk/records_to_render/$filename.images_generated"

		if [ -f $sleeptalk_file_path ]; then

			mp3_file_path="/usr/sleeptalk/records_to_render/$filename.mp3"

			echo "... transcoding wav to mp3 ($audio_file_path to $mp3_file_path)"

			# Thanks to
			# * http://spielwiese.la-evento.com/hokuspokus/seite2.html
			ffmpeg -y -i "$audio_file_path" "$mp3_file_path" >/dev/null 2>&1

			echo "... done transcoding wav to mp3"

			images_file_path="/usr/sleeptalk/records_to_render/${filename}_%04d.png"
			video_file_path="/usr/sleeptalk/records_to_render/${filename}_no_sound.mp4"

			echo "... rendering images to video (${images_file_path} to ${video_file_path})"

			# Thanks to
			# * https://trac.ffmpeg.org/wiki/Create%20a%20video%20slideshow%20from%20images
			ffmpeg -y -framerate 15 -i "$images_file_path" -c:v libx264 -r 30 -pix_fmt yuv420p "$video_file_path" >/dev/null 2>&1

			echo "... done rendering images to video"

			final_video_file_path="/usr/sleeptalk/records_to_render/$filename_no_sound.mp4"

			echo "... concating audio and video ($mp3_file_path + $video_file_path to $final_video_file_path)"

			ffmpeg -y -i "$video_file_path" -i "$mp3_file_path" -map 0:v -map 1:a -vcodec copy -acodec copy -shortest "$final_video_file_path" >/dev/null 2>&1

			echo "... done concating audio and video"

			echo "... deleting mp3 file and no-sound video ($mp3_file_path + $video_file_path)"

			rm $video_file_path
			rm $mp3_file_path




# todo: time counter


			




			echo "... done"

		else

			echo "... no \".images_generated\" file found for \"$filename\""

		fi

		echo ""

		file_counter=$((file_counter + 1))
	fi
done

if [ -n "$file_counter" ]; then
    echo "Done rendering videos, processed files: ${file_counter}"
else
	echo "Done rendering videos, no files found";
fi