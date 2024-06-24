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
extern puts
extern gets
extern sscaf
section		.data
	msjFyC db "Ingrese una fila y una columna(1 a 5) con un espacio",10,0
	formato db "%hi %hi",0 ; 2bytes = 16bits = word = %hi
	matriz dw 1,1,1,1,1
		   dw 2,2,2,2,2
		   dw 3,3,3,3,3
		   dw 4,4,4,4,4
		   dw 5,5,5,5,5

    msjSumatoria db "La sumatoria es: %li",0
    sumatoria dq 0


section		.bss
	filaColumna resb 10
	InputValido resb 1
	fila resq 1
	col resq 1
section		.text

;rax es el registro que siempre recibe el resultado de las funciones de C
main:
pedirFyC:
	mov rsi,msjFyC
	call puts
	mov filaColumna
	call gets
	
	call validarFyC
	cmp byte[InputValido],'N'
	je pedirFyC
	;ahora es valido
	call calcularDesplaz

	call calcularSumatoria

	mov rdi,msjSumatoria
	mov rsi,[sumatoria]
	call printf
	
	ret

;UNA RUTINA INTERNA DENTRO <NO> TIENE QUE HABER UN JUMP
;FUERA DE LA RUTINA
;SI NO SE HACE LIO
validarFyC:
	mov byte[InputValido],'N'
	mov rdi,filaColumna
	mov rsi,formato
	mov rdx,fila
	mov rcx,col  
	call sscanf
	cmp rax,2
	jle invalido

	cmp word[fila],1
	jl invalido
	cmp word[fila],5
	jg invalido

	cmp word[col],1
	jl invalido
	cmp word[col],5
	jg invalido

	mov byte[InputValido],'S'
invalido:
	ret
;ubicar fila y col en la matriz
calcularDesplaz:
	mov		rax,[fil]			;rax = fila
	dec		rax						;fila-1
	imul	rax,2	;(fila-1) * longElem
	imul	rax,5	;(fila-1) * longElem * cantCol => (fila-1) * longFila

	mov		rbx,rax				;rbx = desplazamiento en fila
	
	mov		rax,[col]			;rax = columna
	dec		rax						;columna-1
	imul	rax,2	;(columna-1) * longElem

	add		rbx,rax				;rbx = desplazamiento total
;rbx = [(fila-1) * longElem * cantCol] + [(columna-1) * longElem]

ret 
calcularSumatoria:
	;como se cuantas veces debo iterar sumando?
	;rta:hago que rcx = cantCol+1 = 5+1 = 6
	;resto rcx-col = 6-3 = 3
	;es decir, sumo tres veces
	 
	mov rcx,6 
	sub rcx,[col]
inicio:
	;add [sumatoria],[matrz+rbx] mal!!! add [variab],[variab]
	sub rax,rax ; rax =0
	add rax,[matriz + rbx]
	add [sumatoria],rax
	add rbx,2
	loop inicio
ret
