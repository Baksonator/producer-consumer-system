; -----------------------------------------
; (c) 2016 Univerzitet "Union" 
; Racunarski fakultet (www.raf.edu.rs)
; 14.2008. Operativni sistemi. Primer7.asm
; 
; Naredba za prevodjenje (MS-DOS):
; nasmw primer7.asm -f bin -o primer7.com
; ------------------------------------------

; S.M. 07.04.2016. v2.

SEGMENT DATA

prazno:   db ' ',0
novired2: db 0ah, 0ah, 0dh,0
Poruka_1: db '14.2008. Operativni sistemi. Primer 7.', 0ah, 0ah, 0dh,0	
Poruka_2: db 'Vec se nalazim u zasticenom rezimu.', 0ah, 0dh
          db 'Izlazim iz programa.', 0ah, 0dh,0

; U poruci 3, prazno mesto iza znaka ozanacava zelenu boju pozadine
; U poruci 5, veliko slovo O iza znaka ozanacava crvenu boju pozadine
Poruka_3: db 'P o z d r a v   i z   I A 3 2   z a s t i c e n o g   r e z i m a ! ',0
Poruka_4: db 0ah, 0dh,'Izlazim iz zasticenog rezima.', 0ah, 0dh,0
Poruka_5: db 'IOzOuOzOeOtOaOkO OzObOoOgO OdOeOlOjOeOnOjOaO OnOuOlOoOmO!O',0
Poruka_6: db 'Tajmer: [ ]',0ah, 0ah, 0ah, 0dh,0	
Poruka_7: db 'P o z d r a v   i z   t a s k a   T A S K _ 1 . '
          db '  P r i t i s n i   E S C   z a   i z l a z   u   T A S K _ 0 . ',0
Poruka_8: db 'Tajmer: [ ]',0ah, 0ah, 0dh, 'Task_0: [ ]', 0ah, 0dh
          db 'Task_1: [    ]', 0ah, 0dh, 'Task_2: [    ]', 0ah, 0dh
		  db 'Task_3: [    ]', 0ah, 0dh, 'Task_4: [    ]', 0ah, 0dh
		  db 'Task_5: [    ]', 0ah, 0dh, 'Task_6: [    ]', 0ah, 0ah, 0dh
		  db 'Popunjenost reda:',0ah, 0dh, 0
Pomocna:  db 'Tu sam', 0ah, 0dh, 0		  
 
