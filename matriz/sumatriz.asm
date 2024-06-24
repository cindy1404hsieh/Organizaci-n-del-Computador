;*******************************************************************************
; sumatriz.asm
; Dada una matriz de 5x5 cuyos elementos son numeros enteros 
; de dos bytes(word), se pide solicitar por teclado un
; nro de fila y columna y realizar la sumatoria de los elementos 
; de la fila elegida a partir de la columna elegida y mostrar el
; resultado por pantalla.
; Se debera validar mediante un rutina interna que los valores ingresados
; sean validos.
;   0 1 2 3 4
;  __________
;0| 4 6 7 2 3
;1| 1 3 2 4 5
;2| 7 2 5 3 1
;3| 1 3 1 4 6
;4| 9 2 1 4 2 

; por ejem: fila 1 col 1
; sumatoria = 3+2+4+5 = 14
;*******************************************************************************
global	main
extern printf
extern sscanf
extern gets

section		.data
	msj_fila_col	 db	"Ingrese una fila (1 a 5) y una columna (1 a 5)separados por un espacio:",10,0

	formato_fila_col db "%hi %hi",0

	sumatoria 		 dq	0

	
	msj_sumatoria    db "La sumatoria es: %lli",10,0

	matriz dw 1,1,1,1,1
		   dw 2,2,2,2,2
		   dw 3,3,3,3,3
		   dw 4,4,4,4,4
		   dw 5,5,5,5,5 


section 	.bss

	fila_col 		resb 50
	fila 			resw 1 ; w por %hi 16 bits
	col 			resw 1	
	InputValido 	resb 1;'S'valido 'N ' invalido
	sumatoria 		resd 1
	desplaz 		resw 1

	plusRsp 		resq 1


section		.text

main:
	mov		rdi,msj_fila_col
	sub  	rax,rax
	call	printf

	mov 	rdi,fila_col 
	call    gets

	call 	validar_fil_col

	cmp 	byte[InputValido],'N'
	je 		main ; si no es valido vuelvo a main para preguntar de nuevo y validar de vuelta

	call 	calcular_desplaz

	call 	calcular_sumatoria

	mov 	rdi,msj_sumatoria
	sub 	rsi,rsi
	mov 	esi,[sumatoria] ;esi: porque es doble la sumatoria
	sub 	rax,rax
	call 	printf
ret ;FIN PROGRAMA PRINCIPAL

*************************************************
;
;				RUTINA INTERNA
;
*************************************************
;UNA RUTINA INTERNA DENTRO <NO> TIENE QUE HABER UN JUMP
;FUERA DE LA RUTINA
;SI NO SE HACE LIO
validar_fil_col:
	mov byte[InputValido], 'N';es_valido = false
	mov rdi,fila_col
	mov rsi,formato_fila_col
	mov rdx,fila
	mov rcx,col 

	call checkAlign ;falta el codigo de chackAlign para poder correr el programa
	sub rsp,[plusRsp];para sscanf de Linux
	call sscanf
	add rsp,[plusRsp];para sscanf
	;sscanf(fila_col,"%hi %hi",fila,col);
	cmp rax,2
	jl invalido;jl si fuese menor

	cmp word[fila],1 ; el rango menor es 1;[fila] entre corchetes es porque comparo el contenido no direccion de fila
	jl invalido
	cmp word[fila],5
	jg invalido

	cmp word[col],1 ; el rango menor es 1;[col] entre corchetes es porque comparo el contenido no direccion de col
	jl invalido
	cmp word[col],5
	jg invalido
	mov byte[InputValido], 'S';es_valido = true

invalido:
ret

calcular_desplaz:
	;  [(fila-1)*longFila]  + [(columna-1)*longElemento]
	;  longFila = longElemento * cantidad columnas
	mov		bx,[fila]
	sub		bx,1
	imul	bx,bx,10		;bx tengo el desplazamiento a la fila

    mov		[desplaz],bx

	mov		bx,[columna]
	dec		bx
	imul	bx,bx,2			; bx tengo el deplazamiento a la columna

    add		[desplaz],bx	; en desplaz tengo el desplazamiento final    

ret
;*********************************
calcular_sumatoria:
    mov		rcx,6
    sub		cx,[columna]
	sub		ebx,ebx
	mov		bx,[desplaz]
sumarSgte:
    sub		eax,eax	
    mov		ax,[matriz + ebx]
    add		[sumatoria],eax
    add		ebx,2
    loop    sumarSgte    
ret
