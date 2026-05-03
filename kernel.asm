; ============================================
; полностью ассемблерное ядро LowKey Mini OS
; максимум кастома - всё настраивается здесь
; ============================================

[bits 16]
[org 0x7e00]

; ============================================
; ═══ настройки кастомизации (меняй здесь) ═══
; ============================================

; цвета (формат: 0x0 + цвет текста)
; 0=чёрный, 1=синий, 2=зелёный, 3=голубой, 4=красный
; 5=пурпурный, 6=коричневый, 7=серый, 8=тёмно-серый
; 9=светло-синий, a=светло-зелёный, b=светло-голубой
; c=светло-красный, d=светло-пурпурный, e=жёлтый, f=белый
COLOR_BORDER    equ 0x0b      ; голубой рамка
COLOR_TITLE     equ 0x0f      ; белый заголовок
COLOR_SUBTITLE  equ 0x0b      ; голубой подзаголовок
COLOR_ACCENT    equ 0x0e      ; жёлтый акцент
COLOR_FOOTER    equ 0x07      ; серый текст снизу
COLOR_BG        equ 0x00      ; чёрный фон

; позиция логотипа (строка 0-24, колонка 0-79)
LOGO_ROW        equ 8         ; строка начала логотипа
LOGO_COL        equ 20        ; колонка начала

; настройки рамки
BORDER_CHAR_H   equ '-'       ; горизонтальная линия
BORDER_CHAR_V   equ '|'       ; вертикальная линия
BORDER_CHAR_CORNER equ '+'    ; углы

; ============================================
; ═══ константы (не трогать) ═══
; ============================================
VIDEO_MEM       equ 0xb8000   ; адрес видеопамяти
SCREEN_W        equ 80        ; ширина экрана
SCREEN_H        equ 25        ; высота экрана

; ============================================
; ═══ точка входа ═══
; ============================================
start:
    ; очистка экрана
    call clear_screen
    
    ; рисование рамки
    call draw_border
    
    ; вывод логотипа
    call draw_logo
    
    ; остановка (это заставка)
.hang:
    hlt
    jmp .hang

; ============================================
; ═══ процедуры (вся логика здесь) ═══
; ============================================

; --------------------------------------------
; очистка экрана - заливает пробелами
; --------------------------------------------
clear_screen:
    push es
    push di
    push ax
    push cx
    
    mov ax, 0xb800          ; сегмент видеопамяти
    mov es, ax
    xor di, di              ; начало
    mov ah, COLOR_BG        ; атрибут (фон)
    mov al, ' '             ; пробел
    mov cx, SCREEN_W * SCREEN_H  ; количество символов
    
    rep stosw               ; заполнение
    
    pop cx
    pop ax
    pop di
    pop es
    ret

; --------------------------------------------
; рисование рамки вокруг экрана
; --------------------------------------------
draw_border:
    push es
    push di
    push ax
    push bx
    push cx
    
    mov ax, 0xb800
    mov es, ax
    mov ah, (COLOR_BG << 4) | COLOR_BORDER  ; атрибут
    
    ; верхняя линия
    xor di, di
    mov al, BORDER_CHAR_H
    mov cx, SCREEN_W
.top_line:
    stosw
    loop .top_line
    
    ; нижняя линия
    mov di, (SCREEN_H - 1) * SCREEN_W * 2
    mov cx, SCREEN_W
.bottom_line:
    stosw
    loop .bottom_line
    
    ; левая и правая линии
    mov cx, SCREEN_H
    mov di, 0
    mov bx, SCREEN_W - 1
.side_loop:
    ; левая
    mov al, BORDER_CHAR_V
    mov [es:di], ax
    ; правая
    mov di, bx
    mov [es:di], ax
    add di, SCREEN_W * 2 + 2
    mov bx, di
    sub bx, 2
    loop .side_loop
    
    ; углы
    mov al, BORDER_CHAR_CORNER
    mov di, 0                           ; левый верх
    mov [es:di], ax
    mov di, (SCREEN_W - 1) * 2          ; правый верх
    mov [es:di], ax
    mov di, (SCREEN_H - 1) * SCREEN_W * 2  ; левый низ
    mov [es:di], ax
    mov di, ((SCREEN_H - 1) * SCREEN_W + SCREEN_W - 1) * 2  ; правый низ
    mov [es:di], ax
    
    pop cx
    pop bx
    pop ax
    pop di
    pop es
    ret

; --------------------------------------------
; вывод строки на экран
; вход: si = адрес строки, bh = строка, bl = колонка, dh = цвет
; --------------------------------------------
print_at:
    push es
    push di
    push ax
    push bx
    push si
    
    mov ax, 0xb800
    mov es, ax
    
    ; расчёт позиции: (bh * 80 + bl) * 2
    mov al, bh              ; строка
    mov ah, SCREEN_W
    mul ah                  ; ax = строка * 80
    xor bh, bh
    add ax, bx              ; + колонка
    shl ax, 1               ; * 2 (байты)
    mov di, ax
    
    mov ah, (COLOR_BG << 4) ; старший байт атрибута
    or ah, dh               ; + цвет текста
    
.print_loop:
    lodsb                   ; al = символ из si
    test al, al             ; конец строки?
    jz .done
    stosw                   ; записать символ + атрибут
    jmp .print_loop
    
.done:
    pop si
    pop bx
    pop ax
    pop di
    pop es
    ret

; --------------------------------------------
; ═══ логотип - здесь меняй текст ═══
; --------------------------------------------
draw_logo:
    push si
    push bx
    
    ; === часть 1: "LOWKEY" (ascii арт) ===
    mov bh, LOGO_ROW
    mov bl, LOGO_COL
    mov dh, COLOR_TITLE
    
    ; строка 1
    mov si, .line1
    call print_at
    inc bh
    
    ; строка 2
    mov si, .line2
    call print_at
    inc bh
    
    ; строка 3
    mov si, .line3
    call print_at
    inc bh
    
    ; строка 4
    mov si, .line4
    call print_at
    inc bh
    
    ; строка 5
    mov si, .line5
    call print_at
    add bh, 2               ; пропуск строки
    
    ; === часть 2: "MINI" ===
    mov bl, LOGO_COL + 10
    mov dh, COLOR_SUBTITLE
    
    mov si, .mini1
    call print_at
    inc bh
    mov si, .mini2
    call print_at
    inc bh
    mov si, .mini3
    call print_at
    inc bh
    mov si, .mini4
    call print_at
    inc bh
    mov si, .mini5
    call print_at
    add bh, 2
    
    ; === часть 3: "OS" ===
    mov bl, LOGO_COL + 18
    mov dh, COLOR_TITLE
    
    mov si, .os1
    call print_at
    inc bh
    mov si, .os2
    call print_at
    inc bh
    mov si, .os3
    call print_at
    inc bh
    mov si, .os4
    call print_at
    inc bh
    mov si, .os5
    call print_at
    
    ; === подпись снизу ===
    mov bh, 22
    mov bl, 28
    mov dh, COLOR_FOOTER
    mov si, .footer
    call print_at
    
    pop bx
    pop si
    ret

; ═══ строки логотипа (меняй для своего дизайна) ═══
; "LOWKEY" в стиле блочных букв
.line1: db " ", 0xde, " ", 0xdb, 0xdb, 0xdb, 0xdb, " ", " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, "  ", 0xdb, 0xdb, 0xdb, 0xdb, 0xdb, 0xdb, " ", 0xdb, 0xdb, "   ", 0xdb, 0xdb, 0
.line2: db " ", 0xdb, 0xdb, " ", " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, "  ", 0xdb, 0xdb, " ", 0xdb, 0xdb, " ", " ", 0xdb, 0xdb, "  ", 0xdb, 0xdb, 0
.line3: db " ", 0xdb, 0xdb, " ", " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, 0xdb, 0xdb, "   ", 0xdb, 0xdb, 0xdb, 0xdb, " ", "  ", 0xdb, 0xdb, 0xdb, " ", 0xdb, 0xdb, 0xdb, 0
.line4: db " ", 0xdb, 0xdb, " ", " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, "  ", 0xdb, 0xdb, " ", 0xdb, 0xdb, " ", " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, 0
.line5: db " ", 0xdf, 0xdf, 0xdf, 0xdf, 0xdb, 0xdb, 0xdf, 0xdf, " ", 0xdb, 0xdb, 0xdb, 0xdb, "  ", 0xdb, 0xdb, " ", 0xdb, 0xdb, " ", " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, 0

; "MINI" в стиле псевдографики
.mini1: db 0xdb, 0xdb, 0xdb, " ", " ", " ", 0xdb, 0xdb, 0xdb, " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, 0
.mini2: db 0xdb, 0xdb, 0xdb, 0xdb, " ", 0xdb, 0xdb, 0xdb, 0xdb, " ", 0xdb, 0xdb, 0xdb, " ", 0xdb, 0xdb, 0xdb, 0xdb, 0
.mini3: db 0xdb, 0xdb, " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, 0
.mini4: db 0xdb, 0xdb, " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, 0xdb, " ", " ", 0xdb, 0xdb, 0
.mini5: db 0xdb, 0xdb, " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, 0

; "OS" в стиле блочных букв
.os1: db " ", 0xdb, 0xdb, 0xdb, 0xdb, 0xdb, 0xdb, " ", 0xdb, 0xdb, 0xdb, 0xdb, 0xdb, 0xdb, 0
.os2: db 0xdb, 0xdb, " ", " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, " ", " ", " ", 0xdb, 0xdb, 0
.os3: db 0xdb, 0xdb, " ", " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, 0xdb, 0xdb, 0xdb, 0xdb, 0
.os4: db 0xdb, 0xdb, " ", " ", 0xdb, 0xdb, " ", " ", " ", " ", 0xdb, 0xdb, " ", 0xdb, 0xdb, 0
.os5: db " ", 0xdf, 0xdf, 0xdf, 0xdf, 0xdb, 0xdb, 0xdf, 0xdf, 0xdb, 0xdb, 0xdb, 0xdb, 0xdb, 0

; подпись
.footer: db "[  ", 0x04, "  LowKey  ", 0x04, "  ", 0x0f, "  Mini OS  ", 0x0f, "  ", 0x02, "  by abrakadam  ", 0x02, "  ]", 0
