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

[bits 16]
[org 0x7c00]
[map symbols stage1.map]

%define STAGE2_FILENAME 'JAVELIN BIN'
%define STAGE2_BUFFER   0x0500
%define DIR_BUFFER      0x7e00
%define FAT_BUFFER      0x8000


root_cluster:
; Usually this dword will be part of a jump instruction. That's cool. 
; We don't need that more than once, though, so once this runs we can use
; the sucker as data. Yeah!
; After calculate_lbas has run, this will contain the LBA of the root
; directory.
jmp entry
times 3-($-$$) nop

%include 'bpb.asm'

; Usually the entry point. Sometimes? A temporary cluster number.
temp_cluster:
entry:
	jmp 0x00:fix_cs
fix_cs:
	mov [bpb_driveNum], dl

init_stack:
	; Initialize segment registers & stack
	cli
	xor ax,ax
	mov ss,ax
	mov ds,ax
	mov es,ax
	mov sp, 0x7bfc
	sti

check_int13h:
	; Check for int 13h extensions
	mov ah, 0x41
	mov bx, 0x55AA
	int 0x13
	jc .no_extensions
	cmp bx, 0xAA55
	je calculate_lbas

.no_extensions:
	; There's a somewhat dangerous assumption here - the top eight bits
	; of read_sector_XXh must be the same.
	mov byte [read_sector_impl], read_sector_02h&0xFF

calculate_lbas:
	; Calculate root cluster and data start addresses
	; root cluster = reserved sectors + (FAT count * sectors per FAT)
	mov ax, [bpb_sectorsPerFAT]
	xor bx, bx
	mov bl, [bpb_numFAT]
	mul bx
	add ax, word [bpb_reservedSectors]
	mov [root_cluster], ax
	mov bx, ax
	; data start = root cluster + (root directory entries * 32) / bytes per sector
	mov ax, [bpb_numRootDirEntries]
	shl ax, 5
	xor dx,dx
	div word [bpb_bytesPerSector]
	add ax, bx 
	mov [data_start], ax

detect_fat_type:
	movzx bp, [bpb_sectorsPerCluster]
	xor ax,ax
	add ax, word [bpb_numSectors]
	jz .skip_cluster_check

	xor dx,dx
	sub ax, [data_start]
	div bp
	cmp ax, 4085
.skip_cluster_check:
	jae .fat16

.fat12:
	; See .no_extensions above.
	mov byte [next_cluster], next_cluster_fat12&0xFF
.fat16:

read_fat:
	; Read the entire FAT into 00:08000.
	xor eax, eax
	mov ax, word [bpb_reservedSectors]
	mov bx, FAT_BUFFER
	mov cx, word [bpb_sectorsPerFAT]
.again:
	call read_sector
	loop .again

	mov ax, [root_cluster]

find_stage2:
	.read_root_dir:
		; Read the next sector of the root directory into 00:07e00.
		xor cx,cx
		mov es,cx
		mov bx, DIR_BUFFER
		mov di, bx
		call read_sector

	.check_name:
		; Check if the filename of the current entry matches stage2.
		mov cx, 11
		mov si, stage2_filename
		repe cmpsb
		jz .found

		; It doesn't. Try the next one.
		add di, 32
		and di, ~31
		; If we've reached the end of the sector, read another.
		cmp di, [bpb_bytesPerSector]
		jnz .check_name

		; Have we read the entire root directory?
		dec dx
		jnz .read_root_dir

	.not_found:
		jmp abject_failure

	.found:
		; This should give us the starting cluster of stage2. Hopefully.
		mov ax, [di+15]

	xor cx,cx
	mov es,cx
	mov bx, STAGE2_BUFFER
read_stage2:
	call read_cluster
	cmp ax,0xFF8
	jl read_stage2

	jmp 0:STAGE2_BUFFER

; --------------------------------
; read_cluster
; input:
;	AX 		- cluster number
; 	ES:BX 	- destination
; output:
; 	AX 		- next cluster
;	ES:BX 	- last byte read + 1
read_cluster:
	push cx
	push ds
	mov [temp_cluster], ax

	; Calculate base LBA
	; First cluster is #2, first sector is data_start
	sub ax, 2
	xor cx, cx
	mov cl, byte [bpb_sectorsPerCluster]
	push cx
	imul cx
	add ax, [data_start]

	; Read them sectors.
	pop cx
.next_sector:
	rep call read_sector
	;loop .next_sector

	mov ax, [temp_cluster]
	; Default to getting next sector for FAT16. If the actual
	; filesystem is FAT12, the correct address will be patched in
	; under detect_fat_type.
	;jmp 0x00:next_cluster_fat16
	db 0xea
next_cluster:
	dw next_cluster_fat16
	dw 0x00


; --------------------------------
; next_cluster_fatXX
; input:
;	AX 		- current cluster
; output:
; 	AX 		- next cluster
next_cluster_fat12:
	mov si,0x800
	mov ds,si

	mov cx, 3
	mul cx
	shr ax, 1

	mov si, ax
	lodsw
	jnc .cluster_even
	shr ax, 4

.cluster_even:
	and ah, 0x0F

	jmp pop_ds_cx_ret

next_cluster_fat16:
	mov si,0x800
	shl ax, 1
	jnc .load
	mov si, 0x1800

.load:
	mov ds,si
	mov si,ax
	lodsw

pop_ds_cx_ret:
	pop ds
	pop cx
	ret


; --------------------------------
; read_sector
; input:
; 	EAX 	- LBA to read
; 	ES:BX 	- destination
; output:
;	EAX 	- next sector
; 	ES:BX 	- last byte read + 1
; 	DX 		- who knows?
%include 'read_sector.asm'


_print_string:
	mov bx, 1
	mov ah, 0x0e
	int 0x10
print_string:
	lodsb
	cmp al, 0
	jnz _print_string
	ret

abject_failure:
	mov si, err_msg
	call print_string

	cli
	hlt

err_msg:
db 'Error', 0
stage2_filename:
db STAGE2_FILENAME

times 510-($-$$) db 0xFF

; Boot signature. Or is it? Is it an LBA instead??? ;)
data_start:
boot_signature:
dw 0xAA55
