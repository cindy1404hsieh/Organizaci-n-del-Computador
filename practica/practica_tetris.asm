global	main
extern fopen
extern fread
extern fclose
extern printf 
extern puts
section		.data
	
	matriz times 300 db ' ';espacio
	registro 	   times 0 dw ''
		fila 	   times 1 db ' ';1-30
		col        times 1 db ' ';1-10
		sentido    times 1 db ' ';A B D I

	msjColTodasOcupadas db "la/s columna/s que estan todas ocupadas son: ",10,0
	colFormato dw "%hhi",10,0
	

	nombreArchivo db "fichas.dat",0
	modo db "r",0
	msjErrorOpen db "error encontrado en abrir archivo",0
	asterisco db "*",0
	letraA db "A",0
	letraB db "B",0
	letraD db "D",0
	letraI db "I",0
	vectorLetras db "ABDI",0

section		.bss
	
	idFicha resb 1
	desplaz resb 1 ;(byte porque elemento de la matriz es de 1byte)
	registroValido resb 1
	filColValido resb 1
	sentidoValido resb 1
	validarColTodaOcupada resb 1
	colActual resb 1
section		.text

main:

	;abrir Archivo y guardarlo en idFicha
	mov 	rdi,nombreArchivo
	mov 	rsi,modo
	sub		rsp,8
	call 	fopen
	add		rsp,8
	
	;si no existe muestro error y termino programa
	;si existe hago todo y fclose y termino programa

	cmp rax,0
	jle errorOPENficha
	mov [idFicha],rax
	;leer idFicha y guardarlo en registro
leerRegistro:
	mov rdi,registro
	mov rsi,3
	mov rdx,1
	mov rcx,[idFicha]
	sub	rsp,8
	call fread
	add	rsp,8

	;si llega al final del archivo 
	cmp rax,0
	jle endOfFile
	
	;validar datos del registro
	;si no es valido leo el proximo registro
	call VALFICHA 
	cmp byte[registroValido],'N'
	je leerRegistro
	;si es correcto calculo promedio del elemento del registro
	;(promedio = suma de los elementos/cantidad de elementos)
	;rbx = [(fila-1) * longElem * cantCol] + [(columna-1) * longElem]
	call cargarMatriz
	;actualizo el mayorPromedio si es necesario hasta terminar de leer idFicha
	jmp leerRegistro

endOfFile:
;printeo mensaje con las columnas que tienen todo *
	mov rdi,msjColTodasOcupadas
	sub	rsp,8
	call puts
	add	rsp,8

	mov byte[colActual],1
	mov rcx,10
sgteCol:
	
	mov byte[hayEspacio],'N'
	call buscarEspacioFila
	cmp byte[hayEspacio],'N'
	je printearCol
	inc [colActual] ;col++
	loop sgteCol

	jmp closeFile

errorOPENficha:
	mov rdi,msjErrOpen
	sub		rsp,8
	call	puts
	add		rsp,8
	jmp finPrograma
closeFile:
	mov rdi,[idFicha]
	sub		rsp,8
	call 	fclose
	add		rsp,8
finPrograma:
ret 

;*******************************
;RUTINA INTERNA DE VALIDACION
;*******************************

VALFICHA:
	mov [registroValido],'N'
	;validacion
	call validarFilCol
	cmp byte[filColValido],'N'
	je finValidarRegistro

	call validarSentido
	cmp byte[diagonalValido],'N'
	je finValidarRegistro
	mov [registroValido],'S'
finValidarRegistro:
ret 

validarFilCol:
	mov [filColValido],'N'
	;validar si es un nro
	;validar si esta dentro del rango
	mov [filColValido],'S'
finValidarFilCol:
ret 

validarSentido:
	mov [registroValido],'N'
	mov 	rbx,0
	mov     rcx,4;4 porque son 4 sentidos
nextSentido:
	push	rcx;apila rcx(4) y lo tiene guardado en la pila

	mov     rcx,1;recien ahi puedo usar rcx,ahora rcx = 1 byte a comparar
	lea		rsi,[sentido] ;copia dir de Sentido en rsi
	lea		rdi,[vectorLetras + rbx]
repe cmpsb ; compara tanto bytes como lo indica rcx entre rsi,rdi
	pop		rcx;desapilo y recupero a 4 de la pila y rcx vuelve a ser 4

	je		sentidoOk
	add		rbx,1
	loop	nextSentido;loop= si rcx no es igual a cero, sigo iterando
	
	jmp  	finValidarSentido
sentidoOk:
	mov [registroValido],'S'
finValidarSentido:
ret 

cargarMatriz:
	;  [(fila-1)*longFila]  + [(columna-1)*longElemento]
	;  longFila = longElemento * cantidad columnas
	mov		al,[fila]
	sub		al,1
	imul	al,al,10		;al tengo el desplazamiento a la fila

    mov		[desplaz],al

	mov		al,[col]
	dec		al
	imul	al,al,1			; al tengo el deplazamiento a la columna

    add		[desplaz],al	; en desplaz tengo el desplazamiento final

    mov rcx,3
iterar:
    mov al,[desplaz]
    mov bl,[asterisco]
    mov byte[matriz + al],bl
    ;si es Arriba
    ;desplaz-10 
    ;si es Bajo
    ;desplaz+10
    ;si es Der
    ;desplaz+1
    ;si es Izq
    ;desplaz-1
    
	mov rax,sentido

	cmp rax,[letraA]
	je letraA
	
	cmp rax,[letraB]
	je letraB
	
	cmp rax,[letraD]
	je letraD
	
	cmp rax,[letraI]
	je letraI
	loop iterar
ret 

letraA:
	sub byte[desplaz],10
ret 
letraB:
	add byte[desplaz],10
ret 
letraD:
	add byte[desplaz],1
ret 
letraI:
	sub byte[desplaz],1
ret 

;voy a buscar en todas las filas la columna actual si hay un espacio,
;si hay, dejo de buscar 
buscarEspacioFila:
	;while i<30 && hayEspacio==N
	mov rcx,0
	mov bl,[colActual]
	mov al,[asterisco] 
moverSgteFila:
	inc rcx ;rcx ++
	cmp byte[matriz + bl],al
	jne espacioEncontrado ;no es * es un espacio
	add bl,10
	cmp rcx,30
	jle moverSgteFila ;si rcx es menor igual que 30
	jmp finBuscarEspacioFila

espacioEncontrado:
	mov byte[hayEspacio],'S'
finBuscarEspacioFila:
ret 

printearCol:
	mov rdi,colFormato
	mov rsi,[colActual]
	call printf
ret 