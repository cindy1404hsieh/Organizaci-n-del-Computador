;******************************************************
; holam.asm
; Ejercicio para trabajar con cadenas de caracteres
; Objetivos
;	- aprender uso de cmpsb y movsb
;******************************************************
global	main
extern	puts
section		.data
	cadena1		db		"1234567890",0 ;
	cadena2		db		"abcdefghij",0
	msjIguales		db	"iguales",0
	msjDistintos	db	"distintos",0

section		.text
main:
;Imprimo las 2 cadenas
	call		imprimirCadenas
;Comparo las 2 cadenas
	mov			rsi,cadena1		;rsi = dir de inicio del string
	mov			rdi,cadena2		;rdi = dir de inicio del otro string
	mov			rcx,10				;rcx = cantidad de bytes a comparar
	repe cmpsb						;prefijo repe + cmpsb para comparar byte x byte mientras sean iguales
	je			iguales
	mov			rdi,msjDistintos
	jmp			informo
iguales:
	mov			rdi,msjIguales
;Informo resultado
informo:
	call		puts

;Copio cadena1 en cadena2
	mov			rsi,cadena1		;rsi = dir de inicio del string origen
	mov			rdi,cadena2		;rdi = dir de inicio del string destino
	mov			rcx,10				;rcx = cantidad de bytes a copiar
	rep movsb							;prefijo rep + movsb para copiar repetidamente tantos bytes como indique rcx
	
;Imprimo las 2 cadenas nuevamente
	call		imprimirCadenas

;Comparo las 2 cadenas nuevamente
	mov			rsi,cadena1
	mov			rdi,cadena2
	mov			rcx,10
	repe cmpsb
	je			iguales2
	mov			rdi,msjDistintos
	jmp			informo2
iguales2:
	mov			rdi,msjIguales
;Informo resultado nuevamente
informo2:
	call		puts

	ret

imprimirCadenas:
	mov			rdi,cadena1
	call		puts
	mov			rdi,cadena2
	call		puts
ret 