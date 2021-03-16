**Graylab ceph bash scripts functionality:**

These scripts provide an organized way to archive large data currently stored on the RDS and not actively used. Storing the data on the Ceph Object Storage system, provided by ACC, reduces the storage costs significantly and enables recovery of the data back to active status. Object Storage is significantly different than file system storage such as provided by RDS, thus this set of scripts is being developed to manage the storing and retrieving steps. The basic concept is to treat a set of files organized in a directory as a cohesive entity that needs to be kept together when archived and later retrieved. An analogy is a box of household goods that are packaged up to be stored in a self-storage facility. While in principle access to individual files in the *box* is possible, the preferred way to retrieve the contents is by retrieving the entire box, unpack it back into the active filesystem and thus have access to the entire cohesive set. After the user is done with the retrieved *box* it can safely be deleted from the active filesystem since the archive copy remains in the Ceph system in pristine condition.

The **ceph_archive** script will create an inventory of the target directory and leave that as an anchor file in the directory’s location. Also create a full record of permissions, ownerships, etc. as an special file in the archive to allow full restoration. The script then uses the rclone utility to copy the entire directory structure (as a *box*) to the OHSU Ceph Objective Storage system, verifies the copy, and optionally removes the entire directory from the active filesystem.

The **ceph_restore** script retrieves the entire directory (as a *box*) back from the Ceph system and applies the original permission and ownership settings. Optionally, it can do a verification check against the inventory file to ensure that all files have been restored.

A **ceph_remove** script that permanently removes the entire *box* from the Ceph system when the archive copy is no longer needed.

**ceph_archive script**

arguments:

-v: verbose output to stdout

-d: dry run mode

-n: do not remove the original directory

dir_names: list of directory names that will each be archived

pseudo-code:

save current directory

for each of the target directories in dir_names

- cd to current directory
- run ceph\_perms.py script which creates the RESTORE.sh script into target directory (to be run to restore permissions during ceph\_restore script)
- report on size (especially useful for dry run)
- store tree structure of target directory tree in file with name/path of target directory with .dir extension
- create relative path to /data/share to facilitate relative restores
- rclone copy target directory to [GrayLabArchive](s3://GrayLabArchive) with relative path from /data/share
- rclone check to verify copy was completed cleanly
- if clean, remove entire source target directory


**ceph_restore script**

arguments:

-v: verbose output to stdout

-d: dry run mode

dir_names: list of directory names that will be restored relative to current directory

pseudo-code:

for each target directory in dir_names
- rclone copy target directory from GrayLabArchive bucket to current directory
- report on size (how?)
- verify complete restore by diff'ing .dir file with current tree (if .dir file available)
- if available, execute RESTORE.sh script to restore permissions


**ceph\_remove script**

arguments:

-v: verbose output to stdout

-d: dry run mode

dir_names: list of directory names that will be removed from the GrayLabArchive bucket

pseudo-code:

for each target directory in dir_names
- report on size (how?) and ask for verification
- rclone purge target directory from GrayLabArchive bucket


**Supporting documentation:**

rclone: <https://rclone.org>

OHSU Ceph system: <http://accdoc.ohsu.edu/main/services/objectstorage/>  (accessible within OHSU only)

