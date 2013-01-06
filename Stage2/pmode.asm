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

section .text

; --------------------------------
; p2r_call
; Inputs:
;   [ESP+4]     - function to call in real mode
;   [ESP+8]     - EAX
;   [ESP+12]    - EBX
;   [ESP+16]    - ECX
;   [ESP+20]    - EDX
; Outputs:
;   EAX     - EAX after call
[global p2r_call]
[bits 32]
p2r_call:
    push ebp
    mov ebp, esp

    ; Store potentially clobbered registers & jump to real mode
    push ebx
    push esi
    push edi
    call pmode_to_real
[bits 16]

    ; Set registers from stack
    mov eax, dword [bp+12]
    mov ebx, dword [bp+16]
    mov ecx, dword [bp+20]
    mov edx, dword [bp+24]

    ; Call function
    mov di, word [bp+8]
    call di

    ; Store resulting EAX
    push eax

    ; Return to protected mode
    call real_to_pmode
[bits 32]
    ; Restore registers
    pop eax
    pop edi
    pop esi
    pop ebx

    mov esp, ebp
    pop ebp
    ret

; --------------------------------
; real_to_pmode
; Inputs:
;   None
; Outputs:
;   None
[global real_to_pmode]
[bits 16]
real_to_pmode:
    ; Pop the return address off the stack, zero-extend it, and push
    ; it back. When 'ret' is executed in protected mode, it will get
    ; the 32 bits it craves.
    pop ax
    push 0x0000
    push ax

    cli

    ; Load GDT
    lgdt [gdtptr]

    ; Enable PE bit in CR0
    mov eax, cr0
    or eax,1
    mov cr0, eax

    ; Jump to protected mode
    jmp 0x08:.in_pmode
[bits 32]
.in_pmode:
    ; Set data segment registers
    mov ax, 0x10
    mov ds,ax
    mov es,ax
    mov fs,ax
    mov gs,ax
    mov ss,ax

    ret

; --------------------------------
; pmode_to_real
; Inputs:
;   None
; Outputs:
;   None
[global pmode_to_real]
[bits 32]
pmode_to_real:
    cli

    ; Jump to 16-bit protected mode
    jmp 0x18:.pm16
[bits 16]
.pm16:
    ; Use 16-bit data selectors
    mov ax, 0x20
    mov ds,ax
    mov es,ax
    mov fs,ax
    mov gs,ax
    mov ss,ax

    ; Load IVT
    lidt [idtptr]

    ; Disable PE bit in CR0
    mov eax, cr0
    and eax, ~1
    mov cr0, eax

    jmp 0x00:.in_rmode
.in_rmode:
    ; Set data segment registers to zero
    xor ax,ax
    mov ds,ax
    mov es,ax
    mov fs,ax
    mov gs,ax
    mov ss,ax

    ; Pop the first sixteen bits of the return address, then skip
    ; over the next sixteen.
    pop ax
    add sp, 2
    sti
    jmp ax

section .data

idtptr:
.size: dw 0x3ff
.offset: dd 0

gdtptr:
.size: dw gdt.end - gdt.null + 1
.offset: dd gdt

[global gdt]
[global gdt.ds16]
gdt:
.null:
    dw 0x0000
    dw 0x0000
    db 0x00
    db 0x00
    db 0x00
    db 0x00
.cs32:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00
.ds32:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00
.cs16:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 10001111b
    db 0x00
.ds16:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 10001111b
    db 0x00
.end:
