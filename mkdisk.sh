#!/bin/bash
# Copyright (c) 2012, Charles O. Goddard
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met: 
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

if [ $# -ne 2 ]; then
    echo 'Usage:'
    echo "$0 <folder> <output>"
    exit 1
fi

if [ -e ~/.mtoolsrc ]; then
    cp ~/.mtoolsrc ~/.mtoolsrc.old
fi


IMAGE=$2
FOLDER=$1

# Calculate appropriate disk size
FOLDER_SIZE_KB=`du -k $FOLDER | awk '{print $1}'`
CYLINDERS=`python -c "from math import ceil; print(int(ceil(ceil($FOLDER_SIZE_KB/1024.0)*1024*1024/16.0/63.0/512.0)))"`
IMAGE_SIZE_MB=`python -c "print(\"%.2f\" % ($CYLINDERS*16*63*512/1024.0/1024.0))"`
echo "Image will be" $CYLINDERS "cylinders, or" $IMAGE_SIZE_MB "megabytes."


# Create blank disk image
dd if=/dev/zero of=$IMAGE bs=504K count=$CYLINDERS &> /dev/null

echo "
drive q:
    file=\"`pwd`/$IMAGE\" partition=1
" > ~/.mtoolsrc

mpartition -I -B mbr.bin q:
mpartition -c -t $CYLINDERS -h 16 -s 63 q:
mformat -v JAVELIN -B Stage1/bin/stage1.bin q:
mcopy $FOLDER/* q:/

if [ -e ~/.mtoolsrc.old ]; then
    mv ~/.mtoolsrc.old ~/.mtoolsrc
else
    rm ~/.mtoolsrc
fi
