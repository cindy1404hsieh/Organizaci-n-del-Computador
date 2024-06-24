global	main
extern fopen
extern fread
extern fclose
extern printf
extern puts
section		.data
	matriz dw 1,1,1,1,1,1,1,1,1
		   dw 2,2,2,2,2,2,2,2,2
		   dw 3,3,3,3,3,3,3,3,3
		   dw 4,4,4,4,4,4,4,4,4
		   dw 5,5,5,5,5,5,5,5,5
		   dw 6,6,6,6,6,6,6,6,6
		   dw 7,7,7,7,7,7,7,7,7
		   dw 8,8,8,8,8,8,8,8,8
		   dw 9,9,9,9,9,9,9,9,9
		   dw 0,0,0,0,0,0,0,0,0

	registro 	   times 0 dw ''
		filaVerSup times 4 db ' ' ;4 por que van a ser 4 cuadrados si es valido el reg
		coluVerSup times 4 db ' '
		filaVerSup times 4 db ' '
		coluVerSup times 4 db ' '

	msjMayorPromedio db "el mayor promedio encontrado del diagonal es: %hi",10,0
	mayorPromedio dw 0
	sumatoriaActual dw 0
	promedioActual dw 0

	nombreArchivo db "diagonales.dat",0
	modo db "rb",0
	msjErrorOpen db "error encontrado en abrir diagonales.dat",0

section		.bss
	idDiagonal resb 1
	desplazamiento resw 1 ;(word porque elemento de la matriz es de 2bytes)
	registroValido resb 1
	distanciaFila resw 1
	distanciaCol resw 1
	cantidadDiagonal resw 1
section		.text

main:

	;abrir Archivo y guardarlo en idDiagonal
	mov 	rdi,nombreArchivo
	mov 	rsi,modo
	sub		rsp,8
	call 	fopen
	add		rsp,8
	
	;si no existe muestro error y termino programa
	;si existe hago todo y fclose y termino programa

	cmp rax,0
	jle errorOPENdiago
	mov [idDiagonal],rax
	;leer idDiagonal y guardarlo en registro
leerRegistro:
	mov rdi,registro
	mov rsi,4
	mov rdx,1
	mov rcx,[idDiagonal]
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
	;si es correcto calculo promedio del elemento del registro
	;(promedio = suma de los elementos/cantidad de elementos)
	;rbx = [(fila-1) * longElem * cantCol] + [(columna-1) * longElem]
	call calcularPromedio
	;comparo con el mayor promedio, si es menor el actual, voy al sgte registro
	mpv rcx,2 ;por 2 bytes
	lea	rsi,[promedioActual] ;copia dir de  en rsi
	lea	rdi,[mayorPromedio]
repe cmpsb
	jle leerRegistro
	;si es mayor,actualizo el mayorPromedio 
	mov rcx,2
	lea	rsi,[promedioActual] ;copia dir de  en rsi
	lea	rdi,[mayorPromedio]
repe movsb
	jmp leerRegistro

	
endOfFile:
;printeo mensaje
	mov rdi,msjMayorPromedio
	mov rsi,mayorPromedio
	sub	rsp,8
	call printf
	add	rsp,8
	
	jmp closeFile

errorOPENdiago:
	mov rdi,msjErrOpen
	sub		rsp,8
	call	puts
	add		rsp,8
	jmp finPrograma
closeFile:
	mov rdi,[idDiagonal]
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
	call validarValorVertice
	cmp byte[verticeValido],'N'
	je finValidarRegistro

	call validarDiagonalidad
	cmp byte[diagonalValido],'N'
	je finValidarRegistro
	mov [registroValido],'S'
finValidarRegistro:
ret 

validarValorVertice:
	mov [registroValido],'N'
	cmp dword[filaVerSup],1
	jl finValidarVertice

	cmp dword[filaVerSup],10
	jg finValidarVertice

	cmp dword[colVerSup],1
	jl finValidarVertice

	cmp dword[colVerSup],10
	jg finValidarVertice

	cmp dword[filaVerInf],1
	jl finValidarVertice

	cmp dword[filaVerInf],10
	jg finValidarVertice

	cmp dword[colVerInf],1
	jl finValidarVertice

	cmp dword[colVerInf],10
	jg finValidarVertice
	
	mov [registroValido],'S'
finValidarVertice:
ret 

validarDiagonalidad:
	mov [registroValido],'N'
	;if(filaVerInf - filaVerSup == colVerInf - colVerSup)
	;es diagonal
	;a demas filaVerInf - filaVerSup  = cantidad de cuadrados
	mov ax,filaVerInf
	sub ax,filaVerSup
	mov [distanciaFila],ax 

	mov ax,colVerInf
	sub ax,colVerSup
	mov [distanciaCol],ax 

	mov ax,[distanciaCol]
	cmp ax,[distanciaFila]
	jne finValidarDiagonalidad

	mov ax,[distanciaFila]
	mov [cantidadDiagonal],ax

	mov [registroValido],'S'
finValidarDiagonalidad:
ret 


;*******************************
;RUTINA INTERNA DE CALCULAR PROMEDIO
;*******************************
calcularPromedio:
	mov word[sumatoria],0
;calculo rbx con la formula y le sumo a rbx+11 cada vez que itero
;11 por ser diagonal
	mov rcx,[cantidadDiagonal]
sumarElementos:
	mov rax,[matriz+rbx]
	add sumatoriaActual,rax
	add rbx,11
	loop sumarElementos
	mov rax, sumatoriaActual
	mov rbx,[cantidadDiagonal]
	idiv rbx ;rax=cociente rdx=resto
	mov [promedioActual],rax
ret 