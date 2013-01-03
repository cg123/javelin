; Copyright (c) 2012, Charles O. Goddard
; All rights reserved.
; 
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met: 
; 
; 1. Redistributions of source code must retain the above copyright notice, this
;    list of conditions and the following disclaimer. 
; 2. Redistributions in binary form must reproduce the above copyright notice,
;    this list of conditions and the following disclaimer in the documentation
;    and/or other materials provided with the distribution. 
; 
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
; ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

bpb:
bpb_oemName:
    times 8 db 0; 'MSDOS5.0'
bpb_bytesPerSector:
    dw 0; 512
bpb_sectorsPerCluster:
    db 0; 1
bpb_reservedSectors:
    dw 0
bpb_numFAT:
    db 0; 2
bpb_numRootDirEntries:
    dw 0; 128
bpb_numSectors:
    dw 0; 1
bpb_mediaType:
    db 0; 0xf8
bpb_sectorsPerFAT:
    dw 0; 9
bpb_sectorsPerTrack:
    dw 0; 18
bpb_numHeads:
    dw 0; 2
bpb_numHiddenSectors:
    dd 0
bpb_numSectorsHuge:
    dd 0
bpb_driveNum:
    db 0
bpb_reserved:
    db 0
bpb_signature:
    db 0; 0x29
bpb_volumeID:
    dd 0; 0x9a3f175d
bpb_volumeLabel:
    times 11 db 0; 'JAVELINBOOT'
bpb_fileSysType:
    times 8 db 0; 'FAT12   '
