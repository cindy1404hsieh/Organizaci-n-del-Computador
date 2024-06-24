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
; "Autor: Anthony De Mello"
; "07archivo.txt"
; imprime el archivo y agrega al final del texto leido la palabra(este no se imprime)
;***************************************************************************
global	main
extern fopen
extern fgets
extern fputs
extern fclose
extern puts
section		.data
	archivo db "07archivo.txt",0
	modo db "r+",0
	idArchivo dq 0
	autor db "Autor: Anthony De Mello",0
	msjErrOpen db "error al abrir el archivo",10,0

section		.bss
	registro resb 81
section		.text


main:
	mov rdi,archivo
	mov rsi,modo
	call fopen
	cmp rax,0
	jg openok
	mov rdi,msjErrOpen
	call puts
	jmp endProg
openok:
	mov [idArchivo],rax
leer:
	mov rdi,registro
	mov rsi,80 ;como quieras
	mov rdx,[idArchivo]
	call fgets

	cmp rax,0
	jle escribir

	mov rdx,registro
	call puts
	jmp leer
escribir:
	mov rdi,autor
	mov rsi,[idArchivo]
	call fputs
	jmp endProg

cerrar:
	mov rdi,[idArchivo]
	call fclose
endProg:
ret