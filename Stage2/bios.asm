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

section .text

; --------------------------------
; rm_i13h_call
[global rm_i13h_call]
rm_i13h_call:
    int 13h
    ret

; --------------------------------
; rm_i13h_buffer_call
; Inputs:
;   ECX     - 20-bit linear address to buffer
[global rm_i13h_buffer_call]
rm_i13h_buffer_call:
    ; Save DS
    push ds

    ; Point DS:SI to the address in ECX
    mov si, cx
    and si,  0x00FFF
    and ecx, 0xFF000
    shr ecx, 4
    mov ds, cx

    ; Interrupt! Whooooooop.
    int 13h

    ; Restore DS
    pop ds
    ret

; --------------------------------
; rm_i13h_has_ext
; Inputs:
;   DL      - drive number
; Outputs:
;   EAX     - 1 if int 13h extensions present, 0 if not
[global rm_i13h_has_ext]
rm_i13h_has_ext:
    mov ah, 0x41
    mov bx, 0x55AA
    int 13h
    jc .no_extensions

    cmp bx, 0xAA55
    jne .no_extensions

    test cx, 1
    jz .no_extensions

    mov eax, 1
    ret

.no_extensions:
    xor eax, eax
    ret

; --------------------------------
; rm_i13h_read
; Inputs:
;   DL      - drive number
;   DH      - head number
;   CH      - cylinder number & 0x3F
;   CL      - sector number | (cylinder number & 0xC0)
;   AL      - number of sectors to read
;   BX      - data buffer
; Outputs:
;   EAX     - dunno
[global rm_i13h_read]
rm_i13h_read:
    mov ah, 2
    int 13h
    ret
