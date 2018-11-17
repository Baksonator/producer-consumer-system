; -----------------------------------------
; (c) 2016 Univerzitet "Union" 
; Racunarski fakultet (www.raf.edu.rs)
; 14.2008. Operativni sistemi. Primer7.asm
; 
; Naredba za prevodjenje (MS-DOS):
; nasmw primer7.asm -f bin -o primer7.com
; ------------------------------------------

; S.M. 07.04.2016. v2.

SEGMENT CODE

KBD_A   equ   060h
EOI     equ   020h

%macro  IZUZETAK 2
%1:
    push ax
    mov  ax, %2                 ; redni broj izuzetka
    jmp  status   
%endmacro

status:					
    push bp
    mov  bp, sp
    push ds                     ; Po pravilu, u ISR sacuvati sve registre
    push es                     
    pushad                           
    mov  bx, D_SEL              ; Moramo ponovo da ucitavamo selektore jer ne znamo gde je nastao prekid
    mov  ds, bx
    mov	 bx, V_SEL
    mov  es, bx                 

; Izgled steka nakon nastanka izuzetka (16-bitni rezim) 
; -----------------------------------------------------
; |     Ako ima gresku              Ako nema gresku   |
; |   -----------------            -----------------  |
; v        FLAGS                         FLAGS        v
;     -----------------            ----------------- 
;            CS                           CS
;     -----------------            -----------------
;            IP                           IP
;     -----------------            ----------------- <
;          Error
;     ----------------- <  
; -----------------------------------------------------

    mov  bx, ax                 ; ax - redni broj izuzetka 
    mov  cx, 2
    mov  dx,exc
    call bin2hex
    cmp  byte [ima_gresku+bx], 0
    je  .nema
    mov  ax, word [ss:bp+4]     ; kodni broj greske
    mov  cx, 4
    mov  dx,err
    call bin2hex
    mov  ax, word [ss:bp+6]     ; IP
    mov  cx, 4
    mov  dx,adr_IP
    call bin2hex
    mov  ax, word [ss:bp+8]     ; CS 
    mov  cx, 4
    mov  dx,adr_CS
    call bin2hex
    jmp .ima
.nema:
    mov  ax, 0                  ; kodni broj greske = 0
    mov  cx, 4
    mov  dx,err
    call bin2hex
    mov  ax, word [ss:bp+4]    	; IP
    mov  cx, 4
    mov  dx,adr_IP
    call bin2hex
    mov  ax, word [ss:bp+6]      ; CS
    mov  cx, 4
    mov  dx,adr_CS
    call bin2hex

    str  word ax
    sub  ax, 28h
    shr  ax,3
    mov  cx, 2
    mov  dx,tr
    call bin2hex

.ima:
   call realni_rezim

; Ispisivanje statusa
; -------------------
    mov  si, izuzetak
    call _print
    mov  si, exc
    call _print
    mov  si, adresa
    call _print
    mov  si, adr_CS
    call _print
    mov  si, dvotacka
    call _print
    mov  si, adr_IP
    call _print
    mov  si, kodni_broj
    call _print
    mov  si, err
    call _print
    mov  si, TR_label
    call _print
    mov  si, tr
    call _print
        
; DOS EXIT preko vracene IVT
; --------------------------
    mov  si, novired2
    call _print
    mov  ax, 4c00h          ; AL sadrzi povratni kod = 0(OK)
    int  21h

    popad                   ; Ovde nikada ne dolazimo                
    pop  es
    pop  ds
    pop  bp
    iret

IZUZETAK ISR_00, 00h
IZUZETAK ISR_01, 01h
IZUZETAK ISR_02, 02h
IZUZETAK ISR_03, 03h
IZUZETAK ISR_04, 04h
IZUZETAK ISR_05, 05h
IZUZETAK ISR_06, 06h
IZUZETAK ISR_07, 07h
IZUZETAK ISR_08, 08h
IZUZETAK ISR_09, 09h
IZUZETAK ISR_0A, 0Ah
IZUZETAK ISR_0B, 0Bh
IZUZETAK ISR_0C, 0Ch
IZUZETAK ISR_0D, 0Dh
IZUZETAK ISR_0E, 0Eh
IZUZETAK ISR_0F, 0Fh
IZUZETAK ISR_10, 10h
IZUZETAK ISR_11, 11h
IZUZETAK ISR_12, 12h
IZUZETAK ISR_13, 13h
IZUZETAK ISR_14, 14h
IZUZETAK ISR_15, 15h
IZUZETAK ISR_16, 16h
IZUZETAK ISR_17, 17h
IZUZETAK ISR_18, 18h
IZUZETAK ISR_19, 19h
IZUZETAK ISR_1A, 1Ah
IZUZETAK ISR_1B, 1Bh
IZUZETAK ISR_1C, 1Ch
IZUZETAK ISR_1D, 1Dh
IZUZETAK ISR_1E, 1Eh
IZUZETAK ISR_1F, 1Fh

ISR_20:
    push ds
    push es                      
    pushad  
    mov  ax, D_SEL		
    mov  ds, ax
    mov  ax, V_SEL
    mov  es, ax 
    add  word [tick],1
    adc  word [tick+2],0
    mov  word bx, 338            ; Pozicija na grafickom ekranu 80*4+9*2 = 338  
    inc  byte [es:bx]            ; Sledeci karakter za iscrtavanje 
    mov  al,EOI			
    out  port_8259M,al
    call scheduler
    popad                           
    pop  es
    pop  ds
    iret

ISR_21:
    push ds
    push es                      
    pushad                          
    mov  ax, D_SEL		
    mov  ds, ax
    in   al,KBD_A
    mov  byte [scancode],al
    mov  al,EOI
    out  port_8259M,al
    popad                           
    pop  es
    pop  ds
    iret


%include 'bin2hex.asm'

SEGMENT     DATA
scancode:   db 0
izuzetak:   db 'Izuzetak br.',0 
adresa:     db ' na adresi: ',0
kodni_broj: db 0ah, 0dh, 'Kodni broj greske: ',0
dvotacka:   db ':',0
TR_label:   db 0ah, 0dh, 'Task: ',0
exc:        db '00',0
err:        db '0000',0 		
adr_CS:     db '0000',0 
adr_IP:     db '0000',0     ; 4 hex cifre za 16-bitni rezim rada
tr:         db '00',0 	

ima_gresku: db 0,0,0,0,0,0,0,0, 1,0,1,1,1,1,1,0
            db 0,1,0,0,0,0,0,0, 0,0,0,0,0,0,0,0
