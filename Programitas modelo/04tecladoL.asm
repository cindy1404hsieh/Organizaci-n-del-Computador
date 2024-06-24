;******************************************************
; teclado.asm
; Ejercicio para ingresar datos de por teclado con gets
; y transformarlos de formato con sscanf
; Objetivos
;	- usar sscanf para convertir de string a numerico
;
;******************************************************
global 	main
extern 	printf
extern  gets
extern	sscanf

section  		.data
	msjIngNum		db	'Ingrese un numero: ',0
	msjImpNum		db	'Usted ingreso %i !!',10,0
	numFormat		db	'%li',0	;%i 32 bits / %li 64 bits

section  		.bss
	buffer		resb	10
	numero		resq	1

section 		.text
main:
	sub  rsp,8	;Corro el puntero a la pila 8 bytes para que el call de la sscanf
							;deje rsp en una dir multiplo de 16
ingresoNumero:
; Ingrese numero
	mov		rdi,msjIngNum
	call	printf

	mov		rdi,buffer
	call	gets

	mov		rdi,buffer		;Parametro 1: campo donde están los datos a leer
	mov		rsi,numFormat	;Parametro 2: dir del string q contiene los formatos
	mov		rdx,numero		;Parametro 3: dir del campo que recibirá el dato formateado
	call	sscanf

	cmp		rax,1			;rax tiene la cantidad de campos que pudo formatear correctamente
	jl		ingresoNumero

; Ud ingreso <numero>
	mov		rdi,msjImpNum
	mov		rsi,[numero]
	call	printf
fin:
	add  rsp,8				;Restauro rsp a su valor original
	ret
