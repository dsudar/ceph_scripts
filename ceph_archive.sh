#!/bin/bash

#
# this script is designed to run under nohup to move a directory tree to archive on OHSU's Ceph/S3 object storage
# usage: ceph_archive.sh [-v] dir_names
#        -v: verbose output
#        -d: dry run mode
#        -n: no removal of original directory
#        dir_names: one or more directory names that need to be archived
#

rmv=1

while getopts "dvn" opt; do
    case $opt in
        v)
            echo "Verbose mode is enabled" >&2
            verbose=1
            ;;
        d)
            echo "Dry run mode is enabled" >&2
            dry=1
            ;;
        n)
            echo "Original directory not removed" >&2
            rmv=0
            ;;
        \?)
            echo "Invalid option -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument" >&2
            exit 1
            ;;
     esac
done
shift "$(($OPTIND -1))"

options=""
if [[ $verbose = 1 ]]; then options=" -v "; fi
if [[ $dry = 1 ]]; then options=" --dry-run "; fi

for arg in "$@"
do
	echo "Processing directory: ${arg}"
	# extract relative path from /home/groups/graylab_share
	fullpath=`readlink -e ${arg}`
	userpath=`echo ${fullpath} | sed 's|/home/groups/graylab_share/||g'`
	cd /home/groups/graylab_share

	# save ownership and modes of all files/dirs in the directory
	python3 /usr/local/bin/ceph_perms.py ${userpath} > ${userpath}/RESTORE.sh

	# get contents to facilitate restoring
	tree ${userpath} > ${userpath}.dir

	# check whether top-level object already exists on destination


	# copy to Ceph bucket
	rclone ${options} copy ${userpath} s3://GrayLabArchive/${userpath}/
	echo "rclone ${options} copy ${userpath} s3://GrayLabArchive"

	# check for clean copy
	# rclone check ${userpath} s3://GrayLabArchive

	# remove local copy unless no is specified or dry run
	if [[ $rmv = 1 ]] && [[ $dry != 1 ]]
	then
		rm -rf ${arg}
	fi

	echo "Done with: ${arg}"
done

echo "Done with all"

