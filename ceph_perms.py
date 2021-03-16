#!/usr/bin/python3

import os
import sys
import argparse
from stat import *

# command line processing of arguments
parser = argparse.ArgumentParser(description='ceph_perms.py: generate a file with all ownership/permission settings for a dir')
parser.add_argument("InPath", help="Provide path to the top of the directory tree")
args = parser.parse_args()

inpath = args.InPath

for root, subdirs, files in os.walk( inpath, topdown = True ):
    for name in subdirs:
        myfile = os.path.join( root, name )
        mystat = os.stat( myfile )
        mymode = oct( S_IMODE(mystat.st_mode) )
        print( "chown %d:%d '%s'" % ( mystat.st_uid, mystat.st_gid, myfile ) )
        print( "chmod %s '%s'" % ( mymode[2:], myfile ) )
    for name in files:
        myfile = os.path.join( root, name )
        mystat = os.stat( myfile )
        mymode = oct( S_IMODE(mystat.st_mode) )
        print( "chown %d:%d '%s'" % ( mystat.st_uid, mystat.st_gid, myfile ) )
        print( "chmod %s '%s'" % ( mymode[2:], myfile ) )

