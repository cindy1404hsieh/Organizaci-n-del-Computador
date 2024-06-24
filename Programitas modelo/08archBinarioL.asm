;***************************************************************************
; fileBinary.asm
; Ejercicio que lee y escribe un archivo binario
; Objetivos
;	- manejo de archivo binario
;	- usar fopen (abrir)
;	- usar fread (leer)
;	- usar rewind (rebobinar)
;	- usar fwrite (escribir)
;	- usar fclose (cerrar)
; 
;***************************************************************************
global		main
extern		printf
extern		puts
extern		fopen
extern		fwrite
extern		rewind
extern		fread
extern		fclose

section		.data
	fileName		db	"08archivo.dat",0
	mode			db	"ab+",0		; modo append binary and read (actualizacion y lectura)
	msgErrOpen		db  "Error en apertura de archivo",0

	registro1	times 0		db	""
							dw	2000	;Se guarda en LITTLE ENDIAN D007 en memoria y cuando se copia en el archivo
							db	"Ricardo   ",0
	
	registro	times 0 		 db ""
				id				 dw 0
				nombre	times 10 db " ",0

	linea			db	"%5i|%s",10,13,0

section		.bss
	fileHandle	resq	1
section		.text
main:
	sub		rsp,8
;	Abro archivo para actualizacion y lectura	
	mov		rdi,fileName	;Parametro 1: dir nombre del archivo
	mov		rsi,mode			;Parametro 2: dir string modo de apertura
	call	fopen					;ABRE el archivo y deja el handle en EAX

	cmp		rax,0					;Error en apertura?
	jg		openOk

;	Error apertura
	mov		rdi,msgErrOpen
	call	puts
	jmp		endProg

openOk:
	mov		[fileHandle],rax
;	Agrego un registro
	mov		rdi,registro1			;Parametro 1: dir area de memoria con datos a copiar
	mov		rsi,12						;Parametro 2: longitud del registro
	mov		rdx,1							;Parametro 3: cantidad de registros
	mov		rcx,[fileHandle]	;Parametro 4: handle del archivo
	call	fwrite						;ESCRIBO registro. Devuelve en rax la cantidad de bytes leidos

;	Rebobino al inicio del archivo	
	mov		rdi,[fileHandle]	;Parametro 1: handle del archivo
	call	rewind						;REBOBINO al inicio del archivo

;	Leo un registro
read:
	mov		rdi,registro			;Parametro 1: dir area de memoria donde se copia
	mov		rsi,12						;Parametro 2: longitud del registro
	mov		rdx,1							;Parametro 3: cantidad de registros
	mov		rcx,[fileHandle]	;Parametro 4: handle del archivo
	call	fread							;LEO registro. Devuelve en rax la cantidad de bytes leidos

	cmp		rax,0				;Fin de archivo?
	jle		eof

;	Imprimo el registro en pantalla
	mov		rdi,linea				;Parametro 1: dir del texto a imprimir por pantalla
		sub rsi,rsi
	mov		si,[id]					;Parametro 2: dato a ser formateado como numero entero decimal
	mov		rdx,nombre			;Parametro 3: dir dato a ser formateado como string
	call	printf
	
	jmp		read

eof:
	mov		rdi,[fileHandle]	;Parametro 1: handle del archivo
	call	fclose
endProg:	
	add		rsp,8
ret 