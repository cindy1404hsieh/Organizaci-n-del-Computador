;***************************************************************************
; vector.asm
; Ejercicio que llena un vector ingresando datos por teclado y luego imprime
; Objetivos
;	- definir un vector con times y resb
;	- manejar un vector usando formula (i-1)*longElem
;	- usar printf con varios parametros de distinto tipo
;
;***************************************************************************
global 	main
extern 	printf

section	.data
	msgSal			db	'Elementos guardados en posicion %i: %i y %s',10,13,0

	vecNom			db "Zulema   ",0,"Elvira   ",0,"Filomena ",0,"Leonor   ",0,"Asunta   ",0
	vecNum			dw	100,-200,32767,40,1979
	
	posicion		dq	5

section	.text
main:
	sub  rsp,8

	mov		rcx,[posicion]	;rcx = posicion
	dec		rcx							;(posicion-1)
	imul	ebx,ecx,2				;(posicion-1)*longElem

	mov		ax,[vecNum+ebx]	;ax = elemento (2 bytes / word)
	cwde									;eax= elemento (4 bytes / doble word)
	cdqe									;rax= elemento (8 bytes / quad word)

	imul	ebx,ecx,10			;(posicion-1)*longElem

	mov		rdi,msgSal			;Param 1: Direccion del mensaje a imprimir
	mov		rsi,[posicion]	;Param 2: Direccion del primer dato a imprimir (numero)
	mov		rdx,rax					;Param 3: Contenido del segundo dato a imprimir (numero) 1979
	lea		rcx,[vecNom+ebx];Param 4: Direccion del tercer dato a imprimir (string) Asunta
	call	printf
fin:
	add  rsp,8
	ret
