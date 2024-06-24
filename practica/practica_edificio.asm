global	main
extern fopen
extern fread
extern fclose
extern printf
extern puts
extern gets
extern sscanf

section		.data
	edificio dd 1,1,1,1,1,1,1,1,1,1,1
		     dd 2,2,2,2,2,2,2,2,2,2,2
		     dd 3,3,3,3,3,3,3,3,3,3,3
		     dd 4,4,4,4,4,4,4,4,4,4,4
		     dd 5,5,5,5,5,5,5,5,5,5,5
		     dd 6,6,6,6,6,6,6,6,6,6,6
		     dd 7,7,7,7,7,7,7,7,7,7,7
		     dd 8,8,8,8,8,8,8,8,8,8,8
		     dd 9,9,9,9,9,9,9,9,9,9,9
		     dd 0,0,0,0,0,0,0,0,0,0,0
		     dd 1,1,1,1,1,1,1,1,1,1,1
		     dd 2,2,2,2,2,2,2,2,2,2,2

	registro 	   times 0 dw ''
		piso       times 2 db ' ' 
		depto      times 1 db ' '
		precio     times 4 db ' '


	nombreArchivo db "precios.dat",0
	modo db "r",0
	msjErrorOpen db "error encontrado en abrir precios.dat",0

	precioStr	 		db "****",0
	precioFormat	    db "%i",0	;32bits (dword)
	precioNum			dd	0		;32bits (dword)

	msjPedirInput db "se solicita un nro de dpto(1-12) y precio separado con un espacio:",10,0 
	inputFormat db "%hhi i",0
	deptoIngresado db 0
	precioIngresado dd 0
	msjMostrarPiso db "piso:%hi",10,0
	pisoActual dw 1

section		.bss
	idPrecio resb 1
	desplazamiento resd 1 ;doubleword 4 bytes=32bits eax ebx ecx edx
	registroValido resb 1
	pisoYDeptoValido resb 1
	precioValido resb 1
	input resb 10
	

section		.text

main:

	;abrir Archivo y guardarlo en idPrecio
	mov 	rdi,nombreArchivo
	mov 	rsi,modo
	sub		rsp,8
	call 	fopen
	add		rsp,8
	
	;si no existe muestro error y termino programa
	;si existe hago todo y fclose y termino programa

	cmp rax,0
	jle errorOPENprecio
	mov [idPrecio],rax
	;leer idPrecio y guardarlo en registro
leerRegistro:
	mov rdi,registro
	mov rsi,7
	mov rdx,1
	mov rcx,[idPrecio]
	sub	rsp,8
	call fread
	add	rsp,8

	;si llega al fin del archivo 
	cmp rax,0
	jle endOfFile
	
	;validar datos del registro
	;si no es valido leo el proximo registro
	call VALREG 
	cmp byte[registroValido],'N'
	je leerRegistro
	;si es correcto cargo en piso y dpto el precio delregistro
	;rbx = [(fila-1) * longElem * cantCol] + [(columna-1) * longElem]
	call cargarMatriz
	;actualizo el mayorPromedio si es necesario hasta terminar de leer idPrecio
	jmp leerRegistro

endOfFile:

	;solicitar un nro de dpto y precio
	;printear todos los nros de piso donde el dpto ingresado 
	;tenga precio INFERIOR al ingresado
pedirInput:
	mov rdi,msjPedirInput
	sub	rsp,8
	call puts
	add	rsp,8

	mov rdi,input
	sub	rsp,8
	call gets
	add	rsp,8

	mov rdi,input   
	mov	rsi,inputFormat   
	mov	rdx,deptoIngresado
	mov rcx,precioIngresado      
	sub	rsp,8
	call sscanf;scaneo a precioStr de un string a un numero y me lo guardo en precioNum
	add	rsp,8
	cmp rax,2
	jl 	pedirInput

	;loop hasta llegar al final de la matriz 12 veces

	mov rcx,12
moverSgteDepto: 
	mov rdi,[desplaz]
	mov rsi,[matriz + rdi]
	cmp rsi,[precioIngresado]
	jl mostrarPantalla ;si es menor al precio ingresado
	add dword[desplaz],48 ;por ser 4bytes*12deptos
	inc word[pisoActual]
	loop moverSgteDepto

	jmp closeFile
mostrarPantalla:
	;printear piso
	mov rdi,msjMostrarPiso
	mov rsi,[pisoActual]
	call printf
ret 
errorOPENprecio:
	mov rdi,msjErrOpen
	sub		rsp,8
	call	puts
	add		rsp,8
	jmp finPrograma
closeFile:
	mov rdi,[idPrecio]
	sub		rsp,8
	call 	fclose
	add		rsp,8
finPrograma:
ret 

;*******************************
;RUTINA INTERNA DE VALIDACION
;*******************************

VALREG:
	mov [registroValido],'N'
	;validacion
	call validarPisoYDepto
	cmp byte[pisoYDeptoValido],'N'
	je finValidarRegistro

	call validarPrecio
	cmp byte[precioValido],'N'
	je finValidarRegistro
	mov [registroValido],'S'
finValidarRegistro:
ret 

validarPisoYDepto:
	mov [pisoYDeptoValido],'N'
	cmp word[piso],1
	jl finValidarPisoYDepto
	cmp word[piso],12
	jg finValidarPisoYDepto

	cmp byte[dpto],1
	jl finValidarPisoYDepto
	cmp byte[depto],12
	jg finValidarPisoYDepto

	mov [pisoYDeptoValido],'S'
finValidarPisoYDepto:
ret 

validarPrecio:
	;validar que sea numerico!
	mov [precioValido],'N'
	mov		rcx,4
	mov		rsi,precio
	mov		rdi,precioStr
rep	movsb;copio precio en precioStr

	mov		rdi,precioStr    
	mov		rsi,precioFormat   
	mov		rdx,precioNum      
	sub		rsp,8
	call	sscanf;scaneo a precioStr de un string a un numero y me lo guardo en precioNum
	add		rsp,8
	cmp rax,1
	jl	finValidarPrecio
	mov [precioValido],'S'
finValidarPrecio:
ret 

cargarMatriz:
	;  [(fila-1)*longFila]  + [(columna-1)*longElemento]
	;  longFila = longElemento * cantidad columnas
	mov		ebx,[piso]
	sub		ebx,1
	imul	ebx,ebx,48		;ebx tengo el desplazamiento a la fila

    mov		[desplaz],ebx

	mov		ebx,[depto]
	dec		ebx
	imul	ebx,ebx,4			; ebx tengo el deplazamiento a la columna

    add		[desplaz],ebx	; en desplaz tengo el desplazamiento final 

    mov 	ebx, [desplaz]
    mov 	rdi,[precio]
    mov 	[matriz + ebx],rdi
    ;[matriz + ebx] = precio
ret 