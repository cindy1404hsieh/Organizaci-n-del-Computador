;***************************************************************************
; fileText.asm 
; Ejercicio que lee y escribe un archivo de texto
; Objetivos
;	- manejo de archivo de texto
;	- usar fopen (abrir)
;	- usar fgets (leer)
;	- usar fputs (escribir)
;	- usar fclose (cerrar)
; Copiar el texto que se encuentra al final en un archivo con nombre "07archivo.txt"
; 
;***************************************************************************
global		main
extern		printf
extern		puts
extern		fopen
extern		fgets
extern		fputs
extern		fclose

section		.data
	fileName		    db	"07archivo.txt",0 ;LA ULTIMA LINEA DEL ARCHIVO DEBE TERMINAR CON UN FIN DE LINEA (ENTER)!!!
	mode				db	"r+",0
	linea				db	"Autor: Anthony De Mello",10,0
	msgErrOpen	db  "Error en apertura de archivo",0
	
section		.bss
	fileHandle	resq	1
	registro	resb	81
section		.text
main:
	sub		rsp,8
;	Abro archivo para lectura y escritura	
	mov		rdi,fileName	;Parametro 1: dir nombre del archivo
	mov		rsi,mode			;Parametro 2: dir string modo de apertura
	call	fopen					;ABRO archivo y deja el handle en RAX

	cmp		rax,0					;Error en apertura?
	jg		openOk

;	Error apertura
	mov		rdi,msgErrOpen
	call	puts
	jmp		endProg

openOk:
	mov		[fileHandle],rax
read:
;	Leo registro
	mov		rdi,registro			;Parametro 1: dir area de memoria donde se copia
	mov		rsi,80						;Parametro 2: cantidad de bytes maximas a leer (o hasta fin de linea)
	mov		rdx,[fileHandle]	;Parametro 3: handle del archivo
	call	fgets							;LEO registro. Devuelve en rax la cantidad de bytes leidos

	cmp		rax,0					;Fin de archivo?
	jle		write

;	Imprimo el registro en pantalla
	mov		rdx,registro
	call	printf
	jmp		read

write:
;	Escribo una linea al final
	mov		rdi,linea					;Parametro 1: dir area de memoria a copiar
	mov		rsi,[fileHandle]	;Parametro 2: handle del archivo
	call	fputs							;ESCRIBO archivo.
close:
;	Cierro el archivo
	mov		rdi,[fileHandle]	;Parametro 1: handle del archivo
	call	fclose						;CIERRO archivo
endProg:
	add		rsp,8
	ret

;************* Texto de prueba para el archivo *******************************	
;¿Cuándo realizar tu sueño?
;- ¿Y cuándo piensas realizar tu sueño? le preguntó el Maestro a su discípulo.
;- Cuándo tenga la oportunidad de hacerlo, respondió este.
;El Maestro le contestó:
;- La oportunidad nunca llega. La oportunidad ya está aquí.
;*****************************************************************************