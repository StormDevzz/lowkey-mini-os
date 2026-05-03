; ============================================
; точка входа ядра
; вызывает kernel_main из kernel.c
; ============================================

[bits 16]
[org 0x7e00]                ; сразу после загрузчика

section .text
    ; переход в kernel_main
    extern kernel_main
    call kernel_main
    
    ; остановка если вернулось
    cli
.halt:
    hlt
    jmp .halt
