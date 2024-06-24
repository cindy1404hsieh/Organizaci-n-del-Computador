extern puts
extern gets
extern printf
extern sscanf
extern fopen
extern fwrite
extern fread
extern fclose

section 	.data
    promedioMasGrande db 0

    sumatoriaDiagonales db 0
    cantElementosDiagonal db 0

    ; Uso estas para recorrer la diagonal
    filaPivote db 0
    colPivote db 0

    archivo  db "diagonales.dat",0
	modo     db "rb",0
	msjError db "Error al leer archivo", 0

    longElemento db 2
	longFila db 20

    desplaz dw 1 
	fila db 0
	columna db 0

section 	.bss
    handler resb 1

    registro times 0 resb 4
        regFilaVertSup resb 1
        regColVertSup resb 1
        regFilaVertInf resb 1
        regColVertInf resb 1

    filaVertSup resb 1
    colVertSup resb 1
    filaVertInf resb 1
    colVertInf resb 1

    matriz times 100 resw 1

    diagonalInvalida resb 1

section 	.text
main:
	mov rdi,archivo
	mov rsi,modo
	sub rsp,8
	call fopen
	add rsp,8

	cmp rax, 0 
	jle errorArchivo
	mov [handler], rax

leerProximaDiagonal:
    mov byte[sumatoriaDiagonales],0
leerRegistro:

	mov rdi, registro
	mov rsi, 4
	mov rdx, 1
	mov rcx, [handler]
	sub rsp, 8
	call fread
	add rsp, 8

	cmp rax, 0 
	jle finArchivo

    sub rsp,8
    call VALREG
    add rsp,8
    cmp byte[diagonalInvalida],"S"
    je leerProximaDiagonal

    mov byte[filaVertSup],regFilaVertSup
    mov byte[colVertSup],regColVertSup
    mov byte[filaVertInf],regFilaVertInf
    mov byte[colVertSup],regColVertInf

    mov byte[filaPivote],filaVertSup
    mov byte[colPivote],colVertSup
    sub rsp,8
    call calcDesplaz
    add rsp,8

    ; Esto me da el promedio
    idiv sumatoriaDiagonales,cantElementosDiagonal
    cmp sumatoriaDiagonales,promedioMasGrande
    ; Si mi promedio leido es mayor al promedio mas grande que hay, lo actualizo
    jle avanzarAProxDiagonal
    mov sumatoriaDiagonales,promedioMasGrande

avanzarAProxDiagonal:
    sub rsp,8
    call leerProximaDiagonal
    add rsp,8
ret

; **************** ;
; RUTINAS INTERNAS ;
; **************** ;
errorArchivo:
	mov rdi, msjError
	sub rsp, 8
	call puts
	add rsp, 8
ret

finArchivo:
    mov rdi,[handler]
    sub rsp, 8
	call fclose
	add rsp, 8

    sub rsp,8
	call imprimirMayorProm
	add rsp, 8

    ;HACER ALGO MAS (PONER PROMEDIO MAS GRANDE)
ret

VALREG:
    mov byte[diagonalInvalida],"N"

    ; Resto las coordenadas de las filas
    sub r8,r8
    sub r9,r9
    mov r8,filaVertSup
    mov r9,filaVertInf
    sub r9,filaVertSup

    ; Resto las coordenadas de las columnas
    sub r10,r10
    sub r11,r11
    mov r10,colVertSup
    mov r11,colVertInf
    sub r11,colVertSup

    ; Si las diferencias son iguales es porque los elementos están en diagonal
    cmp r11,r9
    jne leerRegistro

    ; Quiero saber cuantos elementos tiene la diagonal. Me fijo si esta resta dio
    ; un numero negativo, y en tal caso, lo hago positivo
    cmp r11,0
    jg cantidadElementosValida

    neg r11
    mov [cantElementosDiagonal],r11

cantidadElementosValida:
    ; La cantidad de elementos de la diagonal es la diferencia + 1
    inc byte[cantElementosDiagonal]
    mov byte[diagonalInvalida],"S"

ret


calcDesplaz:
    mov rcx,cantElementosDiagonal
promedioElementosDiagonal:

    inc byte[filaPivote]
	inc byte[colPivote]

	sub rax,rax
	mov al,[filaPivote]
	dec rax
	sub r8,r8
	imul rax,[longFila] 
	
    sub rbx, rbx
    mov bl, [colPivote]
    dec rbx
	sub r9,r9
    imul rbx, [longElemento]
    
    add ax,bx    
    mov [desplaz],ax

    sub r10, r10
    mov r10w, [matriz + eax]

	sub r11, r11
	mov r11w,[sumatoriaDiagonales]

	add r11, r10

	mov [sumatoriaDiagonales],r11w

    loop promedioElementosDiagonal

ret

imprimirMayorProm:
    