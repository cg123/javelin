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

global entry
global enable_a20

extern real_to_pmode
extern pmode_to_real

extern p2r_call

extern cmain

section .bootstrap
[bits 16]
entry:
    cli

    xor ax,ax
    mov ss,ax
    mov sp,stacktop

    push 0
    push dx

    call enable_a20
    call real_to_pmode
[bits 32]
    call cmain
    add sp, 4
    cli
    hlt


section .text

enable_a20:
    cli
    call    .wait
    mov     al,0xAD
    out     0x64,al

    call    .wait
    mov     al,0xD0
    out     0x64,al

    call    .wait2
    in      al,0x60
    push    eax

    call    .wait
    mov     al,0xD1
    out     0x64,al

    call    .wait
    pop     eax
    or      al,2
    out     0x60,al

    call    .wait
    mov     al,0xAE
    out     0x64,al

    call    .wait
    sti
    ret

.wait:
    in      al,0x64
    test    al,2
    jnz     .wait
    ret

.wait2:
    in      al,0x64
    test    al,1
    jz      .wait2
    ret

section .bss
resd 4096
[align 4096]
stacktop:
