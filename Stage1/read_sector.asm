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

; --------------------------------
; read_sector
; input:
; 	EAX 	- LBA to read
; 	ES:BX 	- destination
; output:
;	EAX 	- next sector
; 	ES:BX 	- last byte read + 1
; 	DX 		- who knows?
read_sector:
	push eax
	pusha

	add eax, dword [bpb_numHiddenSectors]

	; Jump to the implementation of read_sector that applies to the BIOS.
	; By default this is int 13h, ah=43h, but if int 13h extensions aren't
	; available this will be patched to jump to the ah=02h implementation.
	; See: check_int13h.
	;jmp 0x00:read_sector_43h
	db 0xea
read_sector_impl:
	dw read_sector_43h
	dw 0x00

read_sector_43h:
	mov cx, 4

.try_read:
	push eax
	mov di, sp

	; Construct read parameter block on stack
	push dword 0 		; LBA high 32 bits
	push eax 			; LBA low 32 bits
	push es 			; buffer segment
	push bx 			; buffer offset
	; Both values are words - pushed as bytes to save code space
	push byte 1 		; number of sectors to read
	push byte 16 		; size of parameter block

	; BIOS interrupt 13h, ah=42h
	; Extended read
	mov si, sp
	mov dl, [bpb_driveNum]
	mov ah, 0x42
	int 0x13

	; Restore stack pointer & sector number
	mov sp, di
	pop eax

	jnc read_sector_read_ok

	; Reset disk and try again
	push ax
	; Int 13h, ah=0 - reset disk system
	xor ah, ah
	int 0x13
	pop ax

	dec cx
	jnz .try_read
	jmp read_sector_fail

read_sector_02h:
	; Calculate CHS
	rol eax,16
	mov dx,ax
	rol eax,16

	div word [bpb_sectorsPerTrack]
	mov di, dx
	inc di
	and di, 0x3F
	; di = 1-based sector number

	xor dx,dx
	div word [bpb_numHeads]
	mov cx, dx
	mov dh, cl
	; dh = head number

	mov dl, [bpb_driveNum]

	mov cx, ax
	xchg ch, cl
	shl cl, 6
	or cx, di
	; ch = cylinder[0:8]
	; cl = oh god fuck the BIOS

	mov di, 3
.try_read:
	mov ax, 0x0201
	int 0x13
	jnc read_sector_read_ok

	; Something's broken. Reset the disk.
	xor ax, ax
	int 0x13
	dec di
	jge .try_read

read_sector_fail:
	jmp abject_failure

read_sector_read_ok:
	popa
	add bx, word [bpb_bytesPerSector]
	jnc .return

	; Carry flag is set - bx has overflown, need to increment ES

	mov dx, es
	add dh, 0x10 ; add 0x1000 to ES
	mov es, dx

.return:
	pop eax
	inc eax
	ret
