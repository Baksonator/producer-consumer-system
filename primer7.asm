; -----------------------------------------
; (c) 2016 Univerzitet "Union" 
; Racunarski fakultet (www.raf.edu.rs)
; 14.2008. Operativni sistemi. Primer7.asm
; 
; Naredba za prevodjenje (MS-DOS):
; nasmw primer7.asm -f bin -o primer7.com
; ------------------------------------------

; S.M. 07.04.2016. v2.

ESC   equ   081h
MAX_NUM equ 9

SEGMENT CODE
ORG 0x100


; ------
task_0:
    call _cls
    mov  si, Poruka_1		
    call _print
    smsw ax		
    bt   ax,1            ; Da li smo vec u zasticenom rezimu (PE=1)?
    jnc  nije_PE         ; Nismo
    mov  si,Poruka_2     ; Jesmo	
    call _print			
    jmp  izlaz

nije_PE:
    mov  si, Poruka_8		
    call _print
    call zasticeni_rezim
    mov  bx,word 658     ; Video pozicija =80*8+9*2
.cekaj:
    inc  byte [es:bx]
    cmp  byte [signal], 3
	;cmp  byte [scancode], ESC
	jne  .cekaj
    ;jl .cekaj
    call realni_rezim
    mov  si,Poruka_4		
    call _print	
izlaz:
    ret	


; ------
task_1:
	mov  cx, 100
	mov  ax, 0
    mov  bx,word 818     ; Video pozicija =80*10+9*2 
	mov  dx, lock_1
	mov  di, 1
	;push ax
	;mov  ax, 100
	;call _sleep
	;pop  ax
	mov  ax, 0
	;call _wait
.T1:
	inc  ax
.con:
	call acquire2
	cmp  byte [podaci], MAX_NUM
	jg  .stani
	
	push cx
	mov  cx, ax
	call _print_number
	pop  cx
	mov  si, [tailic]
	add  si, si
	add  si, numbers
	mov  [si], ax
	inc  byte [podaci]
	inc  byte [tailic]
	cmp  byte [tailic], 10
	jl   .normalno
	mov  byte [tailic], 0
	
.normalno:
	call ispisi_popunjenost
	call _notifyAll
	call release2
	
	loop .T1
	call acquire3
	inc  byte [signal]
	call release3
	jmp  $
	;inc  byte [es:bx]
	;jmp  .T1
.stani:
	;push bx
	;push cx
	;mov  bx, 1458
	;mov  cx, [try]
	;inc  byte [try]
	;call _print_number
	;pop  cx
	;pop  bx
	call release2
	call _wait
	jmp  .con
	
task_2:
	mov   word bx, 978 
	mov  cx, 100
	mov  ax, 100
	mov  dx, lock_2
	mov  di, 2
	mov  ax, 100
	;call _sleep								;test za sleep
	mov   ax, 100
	;call _wait
.T2:
	inc  ax
.con:
	call acquire2
	cmp  byte [podaci], MAX_NUM
	jg  .stani
	
	push cx
	mov  cx, ax
	call _print_number
	pop  cx
	mov  si, [tailic]
	add  si, si
	add  si, numbers
	mov  [si], ax
	inc  byte [podaci]
	inc  byte [tailic]
	cmp  byte [tailic], 10
	jl   .normalno
	mov  byte [tailic], 0
	
.normalno:
	call ispisi_popunjenost
	call _notifyAll
	call release2
	
	loop .T2
	call acquire3
	inc  byte [signal]
	call release3
	jmp  $
	;inc  byte [es:bx]
	;jmp  .T1
.stani:
	;push bx
	;push cx
	;mov  bx, 1618
	;mov  cx, [try2]
	;inc  byte [try2]
	;call _print_number
	;pop  cx
	;pop  bx
	call release2
	call _wait
	jmp  .con
	;inc   byte [es:bx]
	;jmp   .T2

; ------
task_3:
    mov  bx,word 1138     ; Video pozicija =80*12+9*2 
	mov  dx, lock_3
	mov  di, 3
	
.T3:
	call acquire2
	cmp  byte [podaci], 0
	je	 .stani
	
	mov  si, numbers
	add	 si, [headic]
	add  si, [headic]
	mov  cx, [si]
	;mov  ax, [numbers + 1]
	;mov  word [numbers], ax
	;mov  ax, [numbers + 2]
	;mov  word [numbers + 1], ax
	;mov  ax, [numbers + 3]
	;mov  word [numbers + 2], ax
	;mov  ax, [numbers + 4]
	;mov  word [numbers + 3], ax
	;mov  ax, [numbers + 5]
	;mov  word [numbers + 4], ax
	;mov  ax, [numbers + 6]
	;mov  word [numbers + 5], ax
	;mov  ax, [numbers + 7]
	;mov  word [numbers + 6], ax
	;mov  ax, [numbers + 8]
	;mov  word [numbers + 7], ax
	;mov  ax, [numbers + 9]
	;mov  word [numbers + 8], ax
	dec  byte [podaci]
	inc  byte [headic]
	cmp  byte [headic], 10
	jl   .normalno
	mov  byte [headic], 0
	
.normalno:
	call ispisi_popunjenost
	call _notifyAll
	call release2
	
	call  _print_number
	;call  _wait
	jmp   .T3
	
.stani:
	call release2
	call _wait
	jmp  .T3

	;call _wait
	;inc  byte [es:bx]
	;jmp  .T3


task_4:
	mov  bx,word 1298     ; Video pozicija =80*12+9*2 
	mov  dx, lock_4
	mov  di, 4
.T4:
	call acquire2
	cmp  byte [podaci], 0
	je	 .stani
	
	;push bx
	;mov  bx, 1458
	;mov  cx, 1
	;call _print_number
	;pop  bx
	mov	 si, numbers
	add  si, [headic]
	add  si, [headic]
	mov  cx, [si]
	;mov  ax, [numbers + 1]
	;mov  word [numbers], ax
	;mov  ax, [numbers + 2]
	;mov  word [numbers + 1], ax
	;mov  ax, [numbers + 3]
	;mov  word [numbers + 2], ax
	;mov  ax, [numbers + 4]
	;mov  word [numbers + 3], ax
	;mov  ax, [numbers + 5]
	;mov  word [numbers + 4], ax
	;mov  ax, [numbers + 6]
	;mov  word [numbers + 5], ax
	;mov  ax, [numbers + 7]
	;mov  word [numbers + 6], ax
	;mov  ax, [numbers + 8]
	;mov  word [numbers + 7], ax
	;mov  ax, [numbers + 9]
	;mov  word [numbers + 8], ax
	dec  byte [podaci]
	inc  byte [headic]
	cmp  byte [headic], 10
	jl   .normalno
	mov  byte [headic], 0
	
.normalno:
	call ispisi_popunjenost
	call _notifyAll
	call release2
	
	call  _print_number
	jmp   .T4
	
.stani:
	call release2
	call _wait
	jmp  .T4

	;inc  byte [es:bx]
	;jmp  .T4
	
task_5:
	mov   word bx, 1458 
	mov  cx, 100
	mov  ax, 200
	mov  dx, lock_5
	mov  di, 5
	;mov  ax, 100
	;call _sleep
	;mov   ax, 100
	;call _wait
.T5:
	inc  ax
.con:
	call acquire2
	cmp  byte [podaci], MAX_NUM
	jg  .stani
	
	push cx
	mov  cx, ax
	call _print_number
	pop  cx
	mov  si, [tailic]
	add  si, si
	add  si, numbers
	mov  [si], ax
	inc  byte [podaci]
	inc  byte [tailic]
	cmp  byte [tailic], 10
	jl   .normalno
	mov  byte [tailic], 0
	
.normalno:
	call ispisi_popunjenost
	call _notifyAll
	call release2
	
	loop .T5
	call acquire3
	inc  byte [signal]
	call release3
	jmp  $
	;inc  byte [es:bx]
	;jmp  .T1
.stani:
	;push bx
	;push cx
	;mov  bx, 1618
	;mov  cx, [try2]
	;inc  byte [try2]
	;call _print_number
	;pop  cx
	;pop  bx
	call release2
	call _wait
	jmp  .con
	;inc   byte [es:bx]
	;jmp   .T2
	
	
task_6:
	mov  bx,word 1618     ; Video pozicija =80*12+9*2 
	mov  dx, lock_6
	mov  di, 6
.T6:
	call acquire2
	cmp  byte [podaci], 0
	je	 .stani
	
	;push bx
	;mov  bx, 1458
	;mov  cx, 1
	;call _print_number
	;pop  bx
	mov	 si, numbers
	add  si, [headic]
	add  si, [headic]
	mov  cx, [si]
	;mov  ax, [numbers + 1]
	;mov  word [numbers], ax
	;mov  ax, [numbers + 2]
	;mov  word [numbers + 1], ax
	;mov  ax, [numbers + 3]
	;mov  word [numbers + 2], ax
	;mov  ax, [numbers + 4]
	;mov  word [numbers + 3], ax
	;mov  ax, [numbers + 5]
	;mov  word [numbers + 4], ax
	;mov  ax, [numbers + 6]
	;mov  word [numbers + 5], ax
	;mov  ax, [numbers + 7]
	;mov  word [numbers + 6], ax
	;mov  ax, [numbers + 8]
	;mov  word [numbers + 7], ax
	;mov  ax, [numbers + 9]
	;mov  word [numbers + 8], ax
	dec  byte [podaci]
	inc  byte [headic]
	cmp  byte [headic], 10
	jl   .normalno
	mov  byte [headic], 0
	
.normalno:
	call ispisi_popunjenost
	call _notifyAll
	call release2
	
	call  _print_number
	jmp   .T6
	
.stani:
	call release2
	call _wait
	jmp  .T6

	;inc  byte [es:bx]
	;jmp  .T4
; ------
_wait:
	call acquire
	push bx
	push cx
	push ax
	mov  cx, 0
	mov  si, dx
	mov  byte bx, [si]
	mov  byte [r_task_queue + di], -1
	mov  byte [si], 1
	call ispisi_redove
	call release
.petlja:
	cmp  byte [si], 0
	je  .kraj
	jmp  .petlja
.kraj:
	pop  ax
	pop  cx
	pop  bx
	ret
	
	
; ------
_notifyAll:
	call acquire
	push ax
	push bx
	push cx
	mov  cx, 6
	mov  bx, 1
	mov  ax, 1
.petlja:
	cmp  byte [r_task_queue + bx], -2
	je   .preskoci
	mov  byte [r_task_queue + bx], al
.preskoci:	
	inc  bx
	inc  ax
	loop .petlja
	mov  byte [lock_1], 0
	mov  byte [lock_2], 0
	mov  byte [lock_3], 0
	mov  byte [lock_4], 0
	mov  byte [lock_5], 0
	mov  byte [lock_6], 0
	call ispisi_redove
	call release
	pop  cx
	pop  bx
	pop  ax
	ret
	
;.preskoci:
	

; ------
_sleep:						;u al br ciklusa
	call acquire4
	;push bx
	mov  si, dx
	;mov  bx, [si]
	mov  byte [r_task_queue + di], -2
	mov  byte [s_task_dur + di], al
	mov  byte [si], 1
	call release4
	push bx
	push cx
	mov  bx, 1878
	mov  cx, 1
	call _print_number
	pop  cx
	pop  bx
.petlja:
	;push bx
	;push cx
	;mov  bx, 1458
	;mov  cx, 1
	;pop  cx
	;pop  bx
	cmp  byte [si], 0
	je  .kraj
	jmp  .petlja
.kraj:
	;pop  bx
	ret
	

	

; ------
acquire:                   ;edx sadrzi adresu mutex promenljive
	push ax
again:
    xor  ax, ax
    xchg word [pera], ax
    test ax, ax         ;ako je eax=0, postavljen je ZF flag
    jnz  uzimam_mutex
    jmp  again    ;call yield kod korisnickih niti
uzimam_mutex:
	pop  ax
    ret

release:
	push ax
	mov  ax, 1
	mov  word [pera], 1
	pop	 ax
    ret
	
acquire2:                   ;edx sadrzi adresu mutex promenljive
	push ax
again2:
    xor  ax, ax
    xchg word [zika], ax
    test ax, ax         ;ako je eax=0, postavljen je ZF flag
    jnz  uzimam_mutex2
    jmp  again2    ;call yield kod korisnickih niti
uzimam_mutex2:
	pop  ax
    ret

release2:
	push ax
	mov  ax, 1
	mov  word [zika], 1
	pop	 ax
    ret
	
acquire3:                   ;edx sadrzi adresu mutex promenljive
	push ax
again3:
    xor  ax, ax
    xchg word [braca], ax
    test ax, ax         ;ako je eax=0, postavljen je ZF flag
    jnz  uzimam_mutex3
    jmp  again3    ;call yield kod korisnickih niti
uzimam_mutex3:
	pop  ax
    ret

release3:
	push ax
	mov  ax, 1
	mov  word [braca], 1
	pop	 ax
    ret
	
acquire4:                   ;edx sadrzi adresu mutex promenljive
	push ax
again4:
    xor  ax, ax
    xchg word [daca], ax
    test ax, ax         ;ako je eax=0, postavljen je ZF flag
    jnz  uzimam_mutex4
    jmp  again4    ;call yield kod korisnickih niti
uzimam_mutex4:
	pop  ax
    ret

release4:
	push ax
	mov  ax, 1
	mov  word [daca], 1
	pop	 ax
    ret
; ------

;ispisi_redove:
;	mov  cx, 0
;	mov  ax, 0
;.petlja:
;	mov  dx, 0
;	mov  byte dl, [r_task_length]
;	cmp  cx, dx
;	jge  .kraj
;	mov  bx, cx
;	mov  dx, 0
;	mov  byte dl, [r_task_queue + bx]
;	inc  cx
;	cmp  dl, -1
;	je   .blok
;.free:
;	mov  bx, 1968
;	push ax
;	mov  ah, 0
;	mov  dh, 10
;	mul  dh
;	add  bx, ax
;	call _print_number
;	pop  ax
;	inc  al
;	jmp  .petlja
;	
;.blok:
;	mov  bx, 2128
;	push ax
;	mov  al, ah
;	mov  ah, 0
;	mov  dh, 10
;	mul  dh
;	add  bx, ax
;	call _print_number
;	pop  ax
;	inc  ah
;	jmp .petlja
;	
;.kraj:
;	ret

ispisi_popunjenost:
	pusha
	mov  bx, 1968
	mov  cx, [podaci]
	call _print_number2
	add  bx, 10
	mov  cx, 10
	call _print_number2
	popa
	ret
	
ispisi_redove:
	pusha
;Ispis reda spremnih
	inc byte[es:100]
	mov bx,104 ; 55. mestu u prvom redu
	mov cx,10
	xor edx,edx
.dva:
	mov al,byte[r_task_queue+edx]
	cmp al,10
	jl .tri
.cetiri:
	cmp al,20
	jl .pet
	jmp .sest
.pet:
	mov byte[es:bx],'1'
	inc bx
	inc bx
	sub al,10
	add al,48
	mov byte[es:bx],al
	inc bx
	inc bx
	inc edx
	jmp .sest
.tri:
	add al,48
	mov byte[es:bx],al
	inc bx
	inc bx
	inc edx
	mov byte[es:bx],' '
	inc bx
	inc bx
	mov byte[es:bx],','
	inc bx
	inc bx
	
.sest:	
	loop .dva
	popa
	ret
	

; ------
_print_number:
	pusha
	mov ax, cx
	and ax, 0f000h					;uzimam prvu hex cifru
	shr ax, 12						;pomeram na al
	call dec_to_hex
	mov byte [es:bx], dl
	inc bx
	;mov byte [es:bx], BOJA
	inc bx
	mov ax, cx
	and ax, 0f00h					;uzimam drugu hex cifru
	shr ax, 8						;pomeram u al
	call dec_to_hex
	mov byte [es:bx], dl
	inc bx
	;mov byte [es:bx], BOJA
	inc bx
	mov ax, cx
	and ax, 00f0h					;treca hex cifra
	shr ax, 4						;pomeram u al
	call dec_to_hex
	mov byte [es:bx], dl
	inc bx
	;mov byte [es:bx], BOJA
	inc bx
	mov ax, cx						
	and ax, 000fh					;poslednja cifra
	call dec_to_hex
	mov byte [es:bx], dl
	;inc bx
	;mov byte [es:bx], BOJA
	;inc bx
	;mov byte [es:bx], SLOVO_H		;malo slovo h
	;inc bx
	;mov byte [es:bx], BOJA
	;inc bx
	popa
	ret
	
dec_to_hex:								;u al je broj koji se pretvara, u dx pretvoren, i to u karakter
	cmp al, 10
	jge vecejednako
	mov dx, ax
	add dx, 30h
	ret
		
vecejednako:
	mov dx, ax
	add dx, 55
	ret
	
_print_number2:
	pusha
	;mov ax, cx
	;and ax, 0f000h					;uzimam prvu hex cifru
	;shr ax, 12						;pomeram na al
	;call dec_to_hex2
	;mov byte [es:bx], dl
	;inc bx
	;mov byte [es:bx], BOJA
	;inc bx
	;mov ax, cx
	;and ax, 0f00h					;uzimam drugu hex cifru
	;shr ax, 8						;pomeram u al
	;call dec_to_hex2
	;mov byte [es:bx], dl
	;inc bx
	;mov byte [es:bx], BOJA
	;inc bx
	mov ax, cx
	and ax, 00f0h					;treca hex cifra
	shr ax, 4						;pomeram u al
	call dec_to_hex2
	mov byte [es:bx], dl
	inc bx
	;mov byte [es:bx], BOJA
	inc bx
	mov ax, cx						
	and ax, 000fh					;poslednja cifra
	call dec_to_hex2
	mov byte [es:bx], dl
	;inc bx
	;mov byte [es:bx], BOJA
	;inc bx
	;mov byte [es:bx], SLOVO_H		;malo slovo h
	;inc bx
	;mov byte [es:bx], BOJA
	;inc bx
	popa
	ret
	
dec_to_hex2:								;u al je broj koji se pretvara, u dx pretvoren, i to u karakter
	cmp al, 10
	jge vecejednako2
	mov dx, ax
	add dx, 30h
	ret
		
vecejednako2:
	mov dx, ax
	add dx, 55
	ret
	
	
%include "pomocni.asm"
%include "ISR.asm"
%include "string.asm"


lock_1:			db 0
lock_2:			db 0
lock_3:			db 0
lock_4:			db 0
lock_5:			db 0
lock_6:			db 0
numbers:	  	TIMES 10 dw 0
podaci:			db 0
signal:			db 0
try:			db 0
try2:			db 0
countNum:		db 0
headic:			db 0
tailic:			db 0