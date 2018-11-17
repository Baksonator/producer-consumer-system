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

C_SEL equ 8
D_SEL equ 16
S_SEL equ 24
V_SEL equ 32
DESCR equ 8

TASK0_SEL equ   028h
MAX_TASKS equ   7       ; taskovi se broje 0, 1, 2 ... 

port_8259M equ  020h
port_8259S equ  0a0h

IZUZETAK_step equ 7     ; duzina koda unutar makroa IZUZETAK

zasticeni_rezim:
    cli                 ; Zabrani hardverske prekide. 
    in   al,070h        ; Zabrani i NMI hardverske prekide.
    or   al,080h        ; Napomena: Ovim nisu zabranjeni softverski
    out  070h,al        ; izazvani prekidi i izuzeci!

; Formiranje baznih adresa (zadrzavamo segmentne adrese iz realnog rezima)
; ------------------------------------------------------------------------
; Kodni segment
    xor  eax,eax
    mov  eax,cs
    shl  eax,4                  ; Siftovanjem segmentnog registra za 4 mesta ulevo 
    mov  dword [gdt_c+2],eax    ; formira se memorijska (bazna) adresa segmenta
    mov  byte [gdt_c+5],09ah	
; Data segment
    xor  eax,eax
    mov  eax,ds
    shl  eax,4
    mov  dword [gdt_d+2],eax
    mov  byte [gdt_d+5],092h
; Stek segment
    xor  eax,eax
    mov  eax,ss
    shl  eax,4
    mov  dword [gdt_s+2],eax
    mov  byte [gdt_s+5],092h

; Bazne adrese za TSS 
; --------------------
    mov  word ax, [tss_size]
    mov  word [gdt_tss_0], ax
    xor  eax,eax
    mov  eax,ds
    shl  eax,4
    add  dword eax, tss_0
    mov  dword [gdt_tss_0+2],eax
    mov  byte [gdt_tss_0+5],089h

    mov  word ax, [tss_size]
    mov  word [gdt_tss_1], ax
    xor  eax,eax
    mov  eax,ds
    shl  eax,4
    add  dword eax, tss_1
    mov  dword [gdt_tss_1+2],eax
    mov  byte [gdt_tss_1+5],089h

    mov  word ax, [tss_size]
    mov  word [gdt_tss_2], ax
    xor  eax,eax
    mov  eax,ds
    shl  eax,4
    add  dword eax, tss_2
    mov  dword [gdt_tss_2+2],eax
    mov  byte [gdt_tss_2+5],089h
	
	mov  word ax, [tss_size]
    mov  word [gdt_tss_3], ax
    xor  eax,eax
    mov  eax,ds
    shl  eax,4
    add  dword eax, tss_3
    mov  dword [gdt_tss_3+2],eax
    mov  byte [gdt_tss_3+5],089h
	
	mov  word ax, [tss_size]
    mov  word [gdt_tss_4], ax
    xor  eax,eax
    mov  eax,ds
    shl  eax,4
    add  dword eax, tss_4
    mov  dword [gdt_tss_4+2],eax
    mov  byte [gdt_tss_4+5],089h
	
	mov  word ax, [tss_size]
    mov  word [gdt_tss_5], ax
    xor  eax,eax
    mov  eax,ds
    shl  eax,4
    add  dword eax, tss_5
    mov  dword [gdt_tss_5+2],eax
    mov  byte [gdt_tss_5+5],089h
	
	mov  word ax, [tss_size]
    mov  word [gdt_tss_6], ax
    xor  eax,eax
    mov  eax,ds
    shl  eax,4
    add  dword eax, tss_6
    mov  dword [gdt_tss_6+2],eax
    mov  byte [gdt_tss_6+5],089h


; GDTR: 32-bita linerana bazna adresa + 16-bitni limit = ukupno 6 bajtova 
; Formiramo lineranu adresu kao sto to radi procesor u realnom rezimu rada 
; ------------------------------------------------------------------------
    xor  eax,eax
    mov  ax,ds			
    shl  eax,4
    add  eax,gdt            ; eax sadrzi lineranu adresu
    mov  dword [gdtr+2],eax
    mov  word [gdtr],95     ; GDT je velicine 8 x 8 stavki (limit = 553)  
    mov  bx, gdtr
    lgdt [ds:gdtr] 

; Formiramo stavke u IDT 
; ----------------------
    mov  cx, 32             ; Broj stavki u IDT
    mov  word di, 0         ; Indeks
    mov  si, ISR_00         ; Adresa prve ISR
init_idt:
    mov  word [idt+2+di], C_SEL
    mov  word [idt+di], si          ; Adrese ISR dispatching (sve su iste velicine)
    add  si, IZUZETAK_step		
    mov  dword [idt+4+di],0
    mov  byte [idt+5+di],10000111b  ; bice prepisano preko prethodne nule
    add  di, 8                      ; 086h - Interrupt Gate, 087h - Trap Gate
    loop init_idt

; ISR za tajmer u IDT
; -------------------
    mov  word [idt+di], ISR_20
    mov  word [idt+di+2], C_SEL     
    mov  byte [idt+di+4], 0
    mov  byte [idt+di+5], 086h
    mov  word [idt+di+6], 0
    add  di, 8                      ; Sledeca stavka u GDT

; ISR za tastaturu u IDT
; ----------------------
    mov  word [idt+di], ISR_21
    mov  word [idt+di+2], C_SEL     
    mov  byte [idt+di+4], 0
    mov  byte [idt+di+5], 086h
    mov  word [idt+di+6], 0

; IDTR: 32-bita linerana bazna adresa + 16-bitni limit = ukupno 6 bajtova 
; Formiramo lineranu adresu kao sto to radi procesor u realnom rezimu rada
; ------------------------------------------------------------------------------ 
    xor  eax,eax
    mov  ax,ds			
    shl  eax,4
    add  eax,idt                     ; eax sadrzi lineranu adresu
    mov  dword [idtr+2],eax
    mov  word [idtr],271             ; IDT je 22h x 8 stavki - 1 (limit = 271)  
    mov  bx, idtr
    lidt [ds:idtr] 

; Sacuvati IRQ maske
; ------------------
    in   al,port_8259M+1
    mov  byte [IRQ_mask],al

    in   al,port_8259S+1
    mov  byte [IRQ_mask+1],al

; Podesavanje PIC-a (Priority Interrupt Controller)
; -------------------------------------------------
    push word 028h                    ; slave vektor prekida
    push word 020h                    ; master vektor prekida
    call _setup_PIC
    pop  cx                           ; oslobodi stek prethodnih argumenata
    pop  cx

; Nove vrednosti IRQ maski
; ------------------------
    mov  al,11111100b                 ; dozvola prekida za tajmer i tastaturu (IRQ0 i IRQ1)	
    out  port_8259M+1,al
    mov  al,11111111b	              ; svi prekidi slave kontrolera su iskljuceni
    out  port_8259S+1,al

; Sacuvati stare segmentne registre zbog povratka u realni rezim
; ------------------------------------------------------------------------------
    mov  [real_CS],cs
    mov  [real_DS],ds
    mov  [real_SS],ss

    mov  eax,cr0        ; Ulaz u zasticeni rezim
    or   eax, dword 1
    mov  cr0,eax
	
    db   106
    db   8
    call _update_cs
    pop  cx

    mov  ax,D_SEL       ; Ostali segment selektori
    mov  ds,ax          ; DS selektor
    mov  ax,S_SEL		
    mov  ss,ax          ; SS selektor
    mov  ax,V_SEL
    mov es,ax           ; Video selektor

; Radi ispravnog prebacivanja taskova, moraju da se inicijaliziju FS i GS
    mov  ax, D_SEL
    mov  fs, ax
    mov  gs, ax

; Iz istog razloga, obrisati LDTR
    mov  ax, 0
    lldt ax

; Pre pvog prebacivanja taska, TSS mora da se inicijalizuje
; Kasnije se to radi automatski (hardver)
; T, IOMAP adresa i LDTR se inicijalizuju staticki za svaki TSS 
; --------------------------------------------------------------
; Task_0 
    mov  word [tss_0+100], 0             ; T = 0
    mov  word [tss_0+102], IOMAP_0
    mov  word [tss_0+96], 0              ; LDTR = 0

; Task_1 
    mov  word [tss_1+100], 0             ; T = 0
    mov  word [tss_1+102], IOMAP_1
    mov  word [tss_1+96], 0              ; LDTR = 0  
    
    mov  word [tss_1+92], 0              ; GS = 0        
    mov  word [tss_1+88], 0              ; FS = 0 
    mov  word [tss_1+84], D_SEL          ; DS 
    mov  word [tss_1+80], S_SEL          ; SS
    mov  word [tss_1+72], V_SEL          ; ES
    mov  word [tss_1+76], C_SEL          ; CS
    xor  eax, eax
    mov  eax, task_1_stack+1023          ; Stek je ovde velicine 1024 bajta. 
    mov  [tss_1+56], eax                 ; ESP pokazuje na vrh steka taska_1.
    mov  word [tss_1+32], task_1         ; EIP pokazuje na pocetak taska_1.
    mov  word [tss_1+36], 0202h          ; Prekidi su dozvoljeni (EFLAGS.9 tj. IF=1. EFLAGS.1 je uvek 1).

; Task_2 
    mov  word [tss_2+100], 0             ; T = 0
    mov  word [tss_2+102], IOMAP_2
    mov  word [tss_2+96], 0              ; LDTR = 0  
    
    mov  word [tss_2+92], 0              ; GS = 0        
    mov  word [tss_2+88], 0              ; FS = 0 
    mov  word [tss_2+84], D_SEL          ; DS 
    mov  word [tss_2+80], S_SEL          ; SS
    mov  word [tss_2+72], V_SEL          ; ES
    mov  word [tss_2+76], C_SEL          ; CS
    xor  eax, eax
    mov  eax, task_2_stack+1023          ; Stek je ovde velicine 1024 bajta. 
    mov  [tss_2+56], eax                 ; ESP pokazuje na vrh steka taska_1.
    mov  word [tss_2+32], task_2         ; EIP pokazuje na pocetak taska_1.
    mov  word [tss_2+36], 0202h          ; Prekidi su dozvoljeni (EFLAGS.9 tj. IF=1. EFLAGS.1 je uvek 1).
	
; Task_3
	mov  word [tss_3+100], 0             ; T = 0
    mov  word [tss_3+102], IOMAP_3
    mov  word [tss_3+96], 0              ; LDTR = 0  
    
    mov  word [tss_3+92], 0              ; GS = 0        
    mov  word [tss_3+88], 0              ; FS = 0 
    mov  word [tss_3+84], D_SEL          ; DS 
    mov  word [tss_3+80], S_SEL          ; SS
    mov  word [tss_3+72], V_SEL          ; ES
    mov  word [tss_3+76], C_SEL          ; CS
    xor  eax, eax
    mov  eax, task_3_stack+1023          ; Stek je ovde velicine 1024 bajta. 
    mov  [tss_3+56], eax                 ; ESP pokazuje na vrh steka taska_1.
    mov  word [tss_3+32], task_3         ; EIP pokazuje na pocetak taska_1.
    mov  word [tss_3+36], 0202h          ; Prekidi su dozvoljeni (EFLAGS.9 tj. IF=1. EFLAGS.1 je uvek 1).
	
; Task_4
	mov  word [tss_4+100], 0             ; T = 0
    mov  word [tss_4+102], IOMAP_4
    mov  word [tss_4+96], 0              ; LDTR = 0  
    
    mov  word [tss_4+92], 0              ; GS = 0        
    mov  word [tss_4+88], 0              ; FS = 0 
    mov  word [tss_4+84], D_SEL          ; DS 
    mov  word [tss_4+80], S_SEL          ; SS
    mov  word [tss_4+72], V_SEL          ; ES
    mov  word [tss_4+76], C_SEL          ; CS
    xor  eax, eax
    mov  eax, task_4_stack+1023          ; Stek je ovde velicine 1024 bajta. 
    mov  [tss_4+56], eax                 ; ESP pokazuje na vrh steka taska_1.
    mov  word [tss_4+32], task_4         ; EIP pokazuje na pocetak taska_1.
    mov  word [tss_4+36], 0202h          ; Prekidi su dozvoljeni (EFLAGS.9 tj. IF=1. EFLAGS.1 je uvek 1).
	
; Task_5
	mov  word [tss_5+100], 0             ; T = 0
    mov  word [tss_5+102], IOMAP_5
    mov  word [tss_5+96], 0              ; LDTR = 0  
    
    mov  word [tss_5+92], 0              ; GS = 0        
    mov  word [tss_5+88], 0              ; FS = 0 
    mov  word [tss_5+84], D_SEL          ; DS 
    mov  word [tss_5+80], S_SEL          ; SS
    mov  word [tss_5+72], V_SEL          ; ES
    mov  word [tss_5+76], C_SEL          ; CS
    xor  eax, eax
    mov  eax, task_5_stack+1023          ; Stek je ovde velicine 1024 bajta. 
    mov  [tss_5+56], eax                 ; ESP pokazuje na vrh steka taska_1.
    mov  word [tss_5+32], task_5         ; EIP pokazuje na pocetak taska_1.
    mov  word [tss_5+36], 0202h          ; Prekidi su dozvoljeni (EFLAGS.9 tj. IF=1. EFLAGS.1 je uvek 1).
	
; Task_6
	mov  word [tss_6+100], 0             ; T = 0
    mov  word [tss_6+102], IOMAP_6
    mov  word [tss_6+96], 0              ; LDTR = 0  
    
    mov  word [tss_6+92], 0              ; GS = 0        
    mov  word [tss_6+88], 0              ; FS = 0 
    mov  word [tss_6+84], D_SEL          ; DS 
    mov  word [tss_6+80], S_SEL          ; SS
    mov  word [tss_6+72], V_SEL          ; ES
    mov  word [tss_6+76], C_SEL          ; CS
    xor  eax, eax
    mov  eax, task_6_stack+1023          ; Stek je ovde velicine 1024 bajta. 
    mov  [tss_6+56], eax                 ; ESP pokazuje na vrh steka taska_1.
    mov  word [tss_6+32], task_6         ; EIP pokazuje na pocetak taska_1.
    mov  word [tss_6+36], 0202h          ; Prekidi su dozvoljeni (EFLAGS.9 tj. IF=1. EFLAGS.1 je uvek 1).

; inicijalizacija reda spremnih
; -----------
	mov	 byte [r_task_head], 1
	mov  byte [r_task_tail], 2
	mov	 byte [r_task_queue], 0
	mov  byte [r_task_queue+1], 1
	mov  byte [r_task_queue+2], 2
	mov  byte [r_task_queue+3], 3
	mov  byte [r_task_queue+4], 4
	mov  byte [r_task_queue+5], 5
	mov  byte [r_task_queue+6], 6
	
; Task_0 u TR
; -----------
    mov  ax, TASK0_SEL
    mov  [task_sel], ax
    ltr  ax

    sti                                  ; Dozvoli hardverske prekide
    ret
	

realni_rezim:

; Izlaz iz zasticenog rezima
; --------------------------
    cli	
    clts  ; TS flag (tj. CR0.3 - Task Switched) = 0 tako da mogu da se startuju DPMI programi 

; FS i GS moraju da se reinicijaliziju za 64KB segmente, da bi se izbegao Unreal Mode 
    mov  ax, D_SEL
    mov  fs, ax
    mov  gs, ax
		
    mov  eax,cr0			
    and  eax, dword 0fffffffeh
    mov  cr0,eax
    jmp .flush32                          ; Isprazniti Prefetch Queue
.flush32:

; Vracanje starih segmentnih registara
; ------------------------------------
    mov  ax, [real_CS] 
    push ax
    call _update_cs
    pop  cx
    mov  ds, [real_DS]
    mov  ax,ds
    mov  es,ax
    mov  ss, [real_SS]

    mov  dword [idtr+2],0    ; vracanje stare IVT 
    mov  word [idtr],1023 	
    lidt [ds:idtr] 

; Podesavanje PIC-a (Priority Interrupt Controller)
; -------------------------------------------------
    push word 070h           ; slave vektor prekida
    push word 8              ; master vektor prekida
    call _setup_PIC
    pop  cx                  ; oslobodi stek prethodnih argumenata
    pop  cx

; Vracanje starih vrednosti IRQ maski
; -----------------------------------
    mov  al,byte [IRQ_mask]
    out  port_8259M+1,al
    mov  al,byte [IRQ_mask+1]
    out  port_8259S+1,al

    mov  dx,word [tick+2]
    mov  ax,word [tick]
    mov  bx,046ch            ; Adresa lokacije BIOS tajmera. 
    add  word [bx],ax        ; Uvecati za broj tickova koji odgovraju vremenu neaktivnosti
    adc  word [bx+2],dx

; Dozvoli prekide
; ---------------
    in   al,070h             ; Dozvoli NMI prekide
    and  al,07Fh
    out  070h,al
    sti                      ; Dozvoli ostale prekide

    ret	

; ------------------------------------
; 16-bitni RR rasporedjivac
; Poziva se iz prekidne rutine tajmera
; ------------------------------------
scheduler:
	;mov  si, Pomocna
	;call _print
	;mov  byte ax, [r_task_head]
	;mov  byte bx, r_task_queue
	;add  bx, ax
	;mov	 si, bx
	;mov  byte ax, [si]
	;mov  bl, 8
	;mul  bl
	;add	 ax, TASK0_SEL
	;mov	 word [task_sel], ax
	;mov  byte ax, [r_task_head]
	;inc  ax
	;mov  byte [r_task_head], al
	;cmp  ax, 3
	;jge  .rev
	;jmp  .switch
	;cmp  word [mutex], 0
	;je   .slabo
	;mov  bx, 1138
	;inc  byte [es:bx]
	;mov  bx, 1138
	;xor	 cx, cx
	;mov  byte cx, [signal]
	;call _print_number
	;mov   bx, 1458
	;xor   cx, cx
	;mov   word cx, [mutex]
	;call  _print_number
	cmp   word [daca], 0
	je   .kraj
	mov  bx, 1
	mov  cx, 6
.petlja:
	cmp  byte [s_task_dur + bx], 0
	je   .nast
	dec  byte [s_task_dur + bx]
	cmp  byte [s_task_dur + bx], 0
	jle  .skini
	inc  bx
	loop .petlja
	jmp  .rad
.nast:
	inc  bx
	loop .petlja
	jmp  .rad
.skini:
	mov  ax, bx
	mov  byte [r_task_queue + bx], al
	inc  bx
	loop .petlja
	jmp  .rad
	
.rad:
	cmp  byte [pera], 0
	je   .kraj
	mov  byte al, [r_task_length]
	cmp  byte [r_task_head], al
	jge  .rev
	mov  bx, 0
	mov  byte bl, [r_task_head]
	;push bx
	;mov  cx, bx
	;mov  bx, 1778
	;call _print_number
	;pop  bx
	mov  byte [truba], bl
	mov  cx, 0
	mov  byte cl, [r_task_queue + bx]
	inc  byte [r_task_head]
	cmp  cl, -1
	jle   scheduler
	shl  cx, 3
	mov  word [task_sel], TASK0_SEL
	add  word [task_sel], cx
	cmp  byte [task_sel], TASK0_SEL+(MAX_TASKS-1)*8
	jle  .switch

.rev:
	mov  word [task_sel], TASK0_SEL
	;mov  byte [truba], 0
	mov  byte [r_task_head], 0
	mov  byte [help], 0
	
;.rev:
	;mov  ax, 0
	;mov  byte [r_task_head], al
    ;add  word [task_sel], 8                                ; Implemetacija RR algoritma
    ;cmp  byte [task_sel], TASK0_SEL+(MAX_TASKS-1)*8   
    ;jle .switch
	;mov  word [task_sel], TASK0_SEL
.switch: 
	mov  byte al, [r_task_head]
	cmp  byte [help], al
	je   scheduler
	mov  byte [help], al
    push word [task_sel]                                   ; Starovati task
    call _jmp_to_tss
    pop  cx
    ret
	
.kraj:
	ret


; -----------------------
_print:
    push ax
    cld
.prn:
    lodsb                ; Ucitavati znakove sve do nailaska prve nule
    or   al,al     
    jz  .end             ; Kraj stringa

    mov  ah,0eh          ; BIOS 10h: ah = 0eh (Teletype Mode), al = znak koji se ispisuje
    int  10h             ; BIOS prekid za rad sa ekranom
    jmp .prn     
.end:
    pop  ax
    ret          

; --------------------------------------

_cls:
    pusha
    mov  ah,02h           ; BIOS 10h: ah = 02h (Postavljanje pozicije kursora)
    mov  dh,0h            ; dh - kolona, dl - red
    mov  dl,0h            ; Pozicija 0,0 (pocetak ekrana - gornji levi ugao)
    int  10h              ; BIOS prekid za rad sa ekranom
    xor  cx,cx            ; Resetovati brojac znakova na vrednost 0
.loop:
    mov  si,prazno
    call _print           ; Ispisivati prazno mesto
    inc  cx
    cmp  cx,2000          ; Standardna velicina alfanumerickog ekrana 80x25 (2000 znakova)
    jne .loop

    mov  ah,02h
    mov  dh,0h            ; Startna pozicija za ispisivanje (0,0)
    mov  dl,0h
    int  10h              ; BIOS prekid za rad sa ekranom

    popa
    ret    

_update_cs:
    push bp
    mov  bp, sp
    mov  ax, [ss:bp+4]   
    push ax              
    push word .1        
    retf                   
.1:
    pop  bp
    retn

_jmp_to_tss:
    push bp
    mov  bp, sp
    jmp  far [ss:bp+2]
    pop  bp
    retn

_setup_PIC:	
    push bp
    mov  bp,sp
    mov  al,011h                 ; pocetak 8259 inicijalizacije
    out  port_8259M,al
    mov  al,011h
    out  port_8259S,al
    mov  al,byte [bp+4]          ; master bazni vektor
    out  port_8259M+1,al
    mov  al,byte [bp+6]          ; slave bazni vektor
    out  port_8259S+1,al
    mov  al,00000100b            ; maska za kaskadnu vezu preko IRQ2
    out  port_8259M+1,al
    mov  al,2                    ; kaskadna veza preko IRQ2
    out  port_8259S+1,al
    mov  al,1                    ; zavrsetak`8259 inicijalizacije
    out  port_8259M+1,al
    mov  al,1
    out  port_8259S+1,al

    pop	bp
    ret	


; --------------------------------------

SEGMENT   DATA

real_CS:  dw 0
real_DS:  dw 0
real_SS:  dw 0
IRQ_mask: dw 0
tick:	  dw 0, 0
task_sel  dw 0

gdtr:
    dw gdte-gdt-1                                   ; limit 
    dd gdt                                          ; bazna adresa
gdt:
gdt_0:  db 0, 0, 0, 0, 0, 0, 0, 0                   ; null deskriptor
gdt_c:  db 0ffh, 0ffh, 0, 0, 0, 09ah, 0, 0          ; kodni segment
gdt_d:  db 0ffh, 0ffh, 0, 0, 0, 092h, 0, 0          ; data segment
gdt_s:  db 0ffh, 0ffh, 0, 0, 0, 092h, 0, 0          ; stek segment
gdt_v:  db 0ffh, 0ffh, 0, 080h, 0bh, 092h, 0, 0     ; video segment (data)

;   Jedna stavka u TSS deskriptoru
;   ================================
;   bajt sadrzaj
;	--------------------------------
;   0    velicina segmenta, donjih 8 bitova
;   1    velicina segmenta, sledecih 8 bitova
;   2    bazna adresa 0
;   3    bazna adresa 1
;   4    bazna adresa 2
;   5    attrib_1
;   6    attrib_2, velicina segmenta gornja 4 bita 
;   7    bazna adresa 3

;            7   6   5   4   3   2   1   0
;  attrib_1  P    DPL    0   1   0   B   1
;  attrib_2  G   0   0  AVL  gornja 4 bita velicine

gdt_tss_0:  dw 103, tss_0, 089h, 0                   ; Staticki inijalizovano, ali se gore radi  
gdt_tss_1:  dw 103, tss_1, 089h, 0                   ; programska inicijalizacija preko ovoga
gdt_tss_2:  dw 103, tss_2, 089h, 0
gdt_tss_3:  dw 103, tss_3, 089h, 0
gdt_tss_4:	dw 103, tss_4, 089h, 0
gdt_tss_5:	dw 103, tss_5, 089h, 0
gdt_tss_6:	dw 103, tss_6, 089h, 0
gdte:

idtr:
    dw idte-idt-1                   ; limit 
    dd idt                          ; bazna adresa

idt:
        TIMES 34*8 db 0
idte:

; Pojedinacni TSS segmenti 
; ------------------------
tss_size: dw tss_1-tss_0-1

tss_0:  TIMES 104 db 0
tss_1:  TIMES 104 db 0
tss_2:  TIMES 104 db 0
tss_3:	TIMES 104 db 0
tss_4:  TIMES 104 db 0
tss_5:  TIMES 104 db 0
tss_6:  TIMES 104 db 0
IOMAP_0:
IOMAP_1:
IOMAP_2:
IOMAP_3:
IOMAP_4:
IOMAP_5:
IOMAP_6:

task_1_stack: TIMES 1024 db 0
task_2_stack: TIMES 1024 db 0
task_3_stack: TIMES 1024 db 0
task_4_stack: TIMES 1024 db 0
task_5_stack: TIMES 1024 db 0
task_6_stack: TIMES 1024 db 0

currTask:		db 0
mutex:			dw 1
mutex_c:		dw 1
current_num:	db 0
;signal:			db 0
help:			db 0
p_number: 		db 0
c_number:		db 0
r_task_length:	db 7
r_task_tail:	db 0
b_task_head:	db 0
b_task_tail:	db 0
r_task_queue: 	times 100 db -1
b_task_queue: 	times 100 db 0
shared_queue:	times 10000 dw 0
s_task_dur:		times 100 db 0
s_queue_head:	dw 0
s_queue_tail:	dw 0
pera:			dw 1
truba:			db 0
r_task_head:	db 0
zika:			dw 1
braca:			dw 1
daca:			dw 1