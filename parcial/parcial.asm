global	main

extern printf 
extern puts
extern gets 
extern sscanf  

section		.data
	matriz times 450 dw ' ';un espacio

	msjPedirInput db "Ingrese un nro representando un pais (1 a 50 inclusive) y con un espacio entre medio un anio:1986, 1990, 1994, 1998, 2002, 2006, 2010, 2014, 2018 ",10,0

	inputFormat db "%hi %hi",0
	paisIngresado dw 0
	anioIngresado dd 0
	
	paisStr	 		db "****",0
	paisFormat	    db "%i",0	;32 bits (double)
	paisNum			dd	0		;32 bits (double)

	vecAnios db "198619901994199820022006201020142018",0
	nroColIngresado dw 0;numero de columna ingresado traducido del anio ingresado
	

	msjInstanciaLlegado db "el pais llego a la instancia: %s",10,0
	msjnoParticipo db "noParticipo",0
	msjfaseGrupos db "faseGrupos",0
	msjoctavosFinal db "octavosFinal",0
	msjcuartosFinal db "cuartosFinal",0
	msjsemiFinal db "semiFinal",0
	msjfinal db "final",0

	msjRecord db "este pais llego %i veces a la semifinal/final",10,0
	contadorRecord dq 0


section		.bss
	input resb 10
	datoValido resb 1
	paisValido resb 1 
	anioValido resb 1
	desplaz resw 1 ;(word porque elemento de la matriz es de 2bytes)
	instanciaLlegado resb 10
	
section		.text

main:

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
	mov	rdx,paisIngresado
	mov rcx,anioIngresado 

	sub	rsp,8
	call sscanf
	add	rsp,8
	cmp rax,2
	jl 	pedirInput ; si fuese menos que 2 variables pido de vuelta

	call VALING
	cmp byte[datoValido],'N'
	je pedirInput ; si fuese invalido los datos ingresados pido de vuelta
	
	
	call imprimirInstancia
	call imprimirRecord

finPrograma:
ret 

;*******************************
;RUTINA INTERNA DE VALIDACION
;*******************************

VALING:
	mov [registroValido],'N'

	call validarPais
	cmp byte[paisValido],'N'
	je finValidarRegistro

	call validarAnio
	cmp byte[anioValido],'N'
	je finValidarRegistro

	mov [registroValido],'S'
finValidarRegistro:
ret 

validarPais:
;valido que este entre 1 y 50
	mov [paisValido],'N'

	cmp	word[paisIngresado],1
	jl	finValidarPais
	cmp	word[paisIngresado],50
	jg	finValidarPais

	mov [paisValido],'S'
finValidarPais:
ret 


validarAnio:
;valido que sea valor numerico y los anios esten correctos	
	mov [anioValido],'N'
	mov		rcx,4
	mov		rsi,anioIngresado
	mov		rdi,anioStr
rep	movsb 

	mov		rdi,anioStr   
	mov		rsi,anioFormat   
	mov		rdx,anioNum      
	sub		rsp,8
	call	sscanf
	add		rsp,8
	cmp rax,1
	jl	finValidarAnio

;valido que este en el vector de anios 
	mov     rbx,0
	mov     rcx,9;9 porque son 9 Anios
nextAnio:
	push	rcx;apila rcx(9) y lo tiene guardado en la pila

	mov     rcx,4;recien ahi puedo usar rcx,ahora rcx = 4,cuantos bytes comparo
	lea		rsi,[anioIngresado] ;copia dir de Anio en rsi
	lea		rdi,[vecAnios + rbx]
repe cmpsb ; compara tanto bytes como lo indica rcx entre rsi,rdi
	pop		rcx;desapilo y recupero a 9 de la pila y rcx vuelve a ser 9
	;guardo la vez de iteracion para guardarme el nro de columna
	inc nroColIngresado ;col++
	je		AnioOk
	add		rbx,4
	loop	nextAnio
	jmp finValidarAnio

AnioOk:
	mov [anioValido],'S'
finValidarAnio:
ret 


;*******************************
;RUTINA INTERNA DE imprimir Instancia
;*******************************
imprimirInstancia:
;calculo desplazamiento
	mov		bx,[paisIngresado]
	sub		bx,1
	imul	bx,bx,18		;18 por longElemento * cantidad columnas= 2bytes * 9 col

    mov		[desplaz],bx

	mov		bx,[nroColIngresado]
	dec		bx
	imul	bx,bx,2			;2 por longElemento = 2 bytes

    add		[desplaz],bx	; en desplaz tengo el desplazamiento final
;comparo los caracteres e    
;imprimo la instancia

	mov bx,[desplaz]
	mov ax,[matriz + bx]

	cmp ax,'NP'
	je noParticipo

	cmp ax,'FG'
	je faseGrupos

	cmp ax,'OF'
	je octavosFinal

	cmp ax,'CF'
	je cuartosFinal

	cmp ax,'SF'
	je semiFinal

	cmp ax,'FI'
	je final

ret
noParticipo:
	mov rdi,msjInstanciaLlegado
	mov rsi,msjnoParticipo
	sub rsp,8
	call printf
	add rsp,8 
ret
faseGrupos:
	mov rdi,msjInstanciaLlegado
	mov rsi,msjfaseGrupos
	sub rsp,8
	call printf
	add rsp,8 
ret
octavosFinal:
	mov rdi,msjInstanciaLlegado
	mov rsi,msjoctavosFinal
	sub rsp,8
	call printf
	add rsp,8 
ret
cuartosFinal:
	mov rdi,msjInstanciaLlegado
	mov rsi,msjcuartosFinal
	sub rsp,8
	call printf
	add rsp,8 
ret
semiFinal:
	mov rdi,msjInstanciaLlegado
	mov rsi,msjsemiFinal
	sub rsp,8
	call printf
	add rsp,8 
ret
final:
	mov rdi,msjInstanciaLlegado
	mov rsi,msjfinal
	sub rsp,8
	call printf
	add rsp,8 
ret 
;*******************************
;RUTINA INTERNA DE imprimir RECORD
;*******************************
imprimirRecord:
;calculo desplazamiento desde columna 1 ya que
;quiero revisar todos los anios
	mov		bx,[paisIngresado]
	sub		bx,1
	imul	bx,bx,18		;18 por longElemento * cantidad columnas= 2bytes * 9 col

    mov		[desplaz],bx

	mov		bx,1 ;1 por columna 1
	dec		bx
	imul	bx,bx,2			;2 por longElemento = 2 bytes

    add		[desplaz],bx	; en desplaz tengo el desplazamiento final


    mov bx,[desplaz]
	mov rcx,9 ;9 por que son 9 anios a iterar
moverSgteAnio:
	;comparo elemento de la matriz con SF y FI
	;si coinciden sumo uno al contador
	
	cmp word[matriz + bx],'SF'
	je  sumarContadorRecord

	
	cmp [matriz + bx],'FI'
	je  sumarContadorRecord

	add bx,2 ;sumo 2 bytes para el siguiente elemento 
	loop moverSgteAnio 

	mov rdi,msjRecord
	mov rsi,[contadorRecord]
	sub rsp,8
	call printf
	add rsp,8 

ret 

sumarContadorRecord:
	inc contadorRecord
ret 