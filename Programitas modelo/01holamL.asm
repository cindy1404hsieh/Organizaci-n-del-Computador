;******************************************************
; holam.asm
; Ejercicio para imprimir "Hola mundo!" por pantalla
; Objetivos
;	- hacer el primer programa en asm linux 64 bits
;	- aprender la estructura de un programa
;	- mostrar mensaje por pantalla usando puts de C
; - aprender los comandos de ensamblado y linkedicion
;		  nasm  01holamL.asm -f elf64
;     gcc   01holamL.o  -o holam.out -no-pie
;     ./holam.out
;******************************************************
global	main
extern	puts
section		.data
	mensaje		db			"Hola mundo!",0		;campo con el string a imprimir.  Debe finalizar con 0 binario

section		.text
main:
	mov			rdi,mensaje		;Parametro 1: direccion del mensaje a imprimir
	call		puts					;puts: imprime hasta el 0 binario y agrega fin de linea
	ret
