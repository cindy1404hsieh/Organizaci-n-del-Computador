global main

extern fopen
extern printf
extern fread
extern fclose
extern sscanf

section .data
mensajePromedio     db "El mayor promedio encontrado es: %lli",0
nombreArchivo       db "diagonales.dat",0
formaLectura        db "rb",0
mensajeErrorLectura	db	"Error en la apertura de arcivo",0
resultadoLectura	dq	0
regsitroValido      db 'N',0
formatoLectura      db "li",0

matrizM times 100   dw 0

mayorPromedio       dq 0
auxPromedio         db 0
promFil             dq 0
auxSumatoria        dq 0
promCol             dq 0
cantidadElementos   dq 0
numeroFisico        dq 0




datos		times	0 	db ''	
	filaVerticeSuperior			times	1	db 0
    ColumnaVerticeSuperior		times	1	db 0
	filaVerticeInferior		    times	1	db 0
	ColumnaVerticeInferior		times	1	db 0

NumfilaVerticeSuperior			db	0
NumColumnaVerticeSuperior		db 0
NumfilaVerticeInferior		    db 0
NumColumnaVerticeInferior		db 0


section .bss


section .text
main:

    mov		rcx,nombreArchivo 
    mov     rdx,formaLectura
    call	fopen;;ABRO EL ARCHIVO

    cmp		rax,0
    jle		errorOpen
    mov     [resultadoLectura],rax

leerRegistro:
    mov     rcx,datos
    mov     rdx,4           
    mov     r8,1
	mov		r9,[resultadoLectura] 

	call    fread

	cmp     rax,0
    jne     verificoDatos

    mov		rcx,[resultadoLectura]
    call	fclose

    mov rcx,mensajePromedio
    mov rdx,[mayorPromedio]
    call 

    ret

verificoDatos:

    call	VALREG 

siguienteRegistro:
	cmp		byte[regsitroValido],'N'
    je		leerRegistro

    ;Si llegue hasta aca significa que el registro es correcto por lo tanto puedo calcular el promedio.

mov rcx,[NumfilaVerticeSuperior]
dec rcx
mov promCol,rcx

mov rcx,[NumColumnaVerticeSuperior]
dec
mov promFil,rcx

calculoPromedio:

    mov rcx,promCol
    inc rcx

    mov rcx,promFil
    inc rcx

    mov rax,[promFil]
    dec rax
    imul rax,2
    imul rax,[promCol]

    mov rbx,rax

    mov cx,[matrizM+rbx]
    add [auxSumatoria],cx

    cmp promCol,10
    jl calculoPromedio

    mov rcx,[auxSumatoria]
    mov rax,[cantidadElementos]
    idiv rcx

    mov [auxPromedio],rax

    mov rcx,[auxPromedio]

    cmp rcx,[mayorPromedio]
    jle leerRegistro

    mov rcx,[auxPromedio]
    mov [mayorPromedio],rcx

    jmp leerRegistro



errorOpen:
	mov		rcx,mensajeErrorLectura
	call	
;Como el el archivo no existe termino el programa.
ret

VALREG:
    mov regsitroValido,'N'

    ;;;Yo voy a tomar como valores validos del 1 al 10. 
        validoFilaVerticeSuperior:
            
        mov		rcx,filaVerticeSuperior    
        mov		rdx,formatoLectura   
        mov		r8,NumfilaVerticeSuperior      
        call	sscanf
        cmp rax,1
        jl	validacionNegativa;Si uno de los datos da error voy a validacion Negativo.

        mov rcx,[NumfilaVerticeSuperior]
        mov numeroFisico,rcx

        mov		rcx,columnaVerticeSuperior    
        mov		rdx,formatoLectura   
        mov		r8,NumColumnaVerticeSuperior      
        call	sscanf
        cmp rax,1
        jl	validacionNegativa;Si uno de los datos da error voy a validacion Negativo.

        mov rcx,[NumColumnaVerticeSuperior]
        mov numeroFisico,rcx

        call validacionFisica

        mov		rcx,filaVerticeInferior    
        mov		rdx,formatoLectura   
        mov		r8,NumfilaVerticeInferior     
        call	sscanf
        cmp rax,1
        jl	validacionNegativa;Si uno de los datos da error voy a validacion Negativo.

        mov rcx,[NumfilaVerticeInferior]
        mov numeroFisico,rcx

        call validacionFisica

        mov		rcx,ColumnaVerticeInferior  
        mov		rdx,formatoLectura   
        mov		r8,NumColumnaVerticeInferior    
        call	sscanf
        cmp rax,1
        jl	validacionNegativa;Si uno de los datos da error voy a validacion Negativo.

        mov rcx,[NumColumnaVerticeInferior]
        mov numeroFisico,rcx

        call validacionFisica       

    ;;si llego hasta signfica que los 4 valores estan entre 1 y 10. Ahora verifico si es correcto los valores dentro de la matriz.

        call verificacionDatosDentroDeMatriz




    validacionFisica:
        mov rcx,[numeroFisico]
        cmp rcx,10
        jg validacionNegativa

        mov rcx,[numeroFisico]
        cmp rcx,1
        jl validacionNegativa

    ret





    validacionNegativa:
        mov regsitroValido,'N'
        jmp siguienteRegistro

    ;Vuelvo a donde estaba antes.


    verificacionDatosDentroDeMatriz:
        ;PAra hacer esta verificacion lo que voy a hacer es ir sumandole 1 al par superior, si llego hasta los inferiores esta ok, si me paso 10 estan mal.
        ;Para mi caso las matrices deben tener almenos 2 elementos 
        mov auxcol,[NumColumnaVerticeSuperior]
        mov auxfil,[NumColumnaVerticeSuperior]

        mov rcx,0
        mov cantidadElementos,rcx

        auxiliar:

            mov rcx,cantidadElementos
            inc rcx
            mov cantidadElementos,rcx

            mov rcx,[auxcol]
            inc rcx
            cmp rcx,10
            jg validacionNegativa

            cmp rcx,[auxfil]
            inc rcx
            cmp rcx,10
            jg validacionNegativa

            mov rcx,[auxcol]
            inc rcx
            cmp rcx,[NumColumnaVerticeInferior]
            jne auxiliar

            mov rcx,[auxfil]
            inc rcx
            cmp rcx,[NumFilaVerticeInferior]
            jne auxiliar
        ;;Si llegaste hasta aca y nunca bifurcaste el registro es correcto.

        mov regsitroValido,'S'
        jmp siguienteRegistro













