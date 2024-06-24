; Dado un archivo en formato BINARIO que contiene informacion sobre autos llamado listado.dat
; donde cada REGISTRO del archivo representa informacion de un auto con los campos: 
;   marca:							10 caracteres
;   año de fabricacion:				4 caracteres
;   patente:						7 caracteres
;	precio							4 bytes en bpf s/s
; Se pide codificar un programa en assembler intel que lea cada registro del archivo listado y guarde
; en un nuevo archivo en formato binario llamado seleccionados.dat las patentes y el precio (en bpfc/s) de aquellos autos
; cuyo año de fabricación esté entre 2020 y 2022 (inclusive) y cuyo precio sea inferior a 5.000.000$
; Como los datos del archivo pueden ser incorrectos, se deberan validar mediante una rutina interna.
; Se deberá validar:
;   Marca (que sea Fiat, Ford, Chevrolet o Peugeot)
;   Año (que sea un valor numérico y que cumpla la condicion indicada del rango) 
;   Precio que sea un valor numerico. 
global	main
extern  puts
extern  printf
extern  fopen
extern  fclose
extern  fread 
extern  sscanf
extern  fwrite

section	.data
	fileListado		db	"listado.dat",0
	modeListado		db	"rb",0		;read | binario | abrir o error
	msjErrOpenLis	db	"Error en apertura de archivo Listado",0
    handleListado	dq	0

	fileSeleccion	db	"seleccion.dat",0
	modeSeleccion	db	"wb",0
	msjErrOpenSel   db	"Error en apertura de archivo seleccion",0
	handleSeleccion	dq	0

	regListado		times	0 	db ''	;Longitud total del registro: 25
	  marca			times	10	db ' '
	  anio			times	4	db ' '
	  patente		times	7	db ' '
	  precio		times	4	db ' '
 
	vecMarcas		db	"Fiat      Ford      Chevrolet Peugeot   "

	anioStr	 		db "****",0
	anioFormat	    db "%hi",0	;16 bits (word)
	anioNum			dw	0		;16 bits (word)  

	regSeleccion	times	0	db	'' ;11 bytes en total
	 patenteSel		times	7	db ' ' ;7 bytes
	 precioSel					dd 0   ;4 bytes

	;*** Para debug
	msjAperturaOk db "Apertura Listado ok",0
	msjLeyendo	db	"leyendo...",0
	charFormat		db "%c",10,0

section .bss
	registroValido	resb    1
	datoValido		resb	1

section  .text
main:
	;Abro archivo listado
    mov		rdi,fileListado 
    mov     rsi,modeListado
	sub		rsp,8
	call	fopen
	add		rsp,8
	;fopen("listado.dat","rb")

	cmp		rax,0
	jle		errorOpenLis
	mov     [handleListado],rax
	
	
mov		rdi,msjAperturaOk
sub		rsp,8
call	puts
add		rsp,8

	;Abro archivo seleccion
	mov		rdi,fileSeleccion
	mov		rsi,modeSeleccion
	sub		rsp,8
	call	fopen
	add		rsp,8

	cmp		rax,0
	jle		errorOpenSel
	mov		[handleSeleccion],rax
leerRegistro:
    mov     rdi,regListado
    mov     rsi,25           
    mov     rdx,1
	mov		rcx,[handleListado] 
	sub		rsp,8  
	call    fread
	add		rsp,8
	;fread(regListado , cant bytes=25 , cant bloques=1,[handleListado]);
	;queda copiado en regListado
	cmp     rax,0
    jle     closeFiles	

mov 	rdi,msjLeyendo
sub		rsp,8
call	puts  
add		rsp,8

	;Valido registro
	sub		rsp,8
	call	validarRegistro
	add		rsp,8
    cmp		byte[registroValido],'N'
    je		leerRegistro

	;Copiar los datos requeridos al archivo de seleccion
	;Copio Patente
	mov		rcx,7
	mov		rsi,patente
	mov		rdi,patenteSel
rep	movsb	

	;Copio precio
	mov		eax,[precio]
	mov		[precioSel],eax


	;Guardo registro en archivo Seleccion
	mov		rdi,regSeleccion			;Parametro 1: dir area de memoria con los datos a copiar
	mov		rsi,11						;Parametro 2: longitud del registro
	mov		rdx,1						;Parametro 3: cantidad de registros
	mov		rcx,[handleSeleccion]		;Parametro 4: handle del archivo
	sub		rsp,8
	call	fwrite
	add		rsp,8

	jmp		leerRegistro


errorOpenLis:
	mov		rdi,msjErrOpenLis
	sub		rsp,8
	call	puts
	add		rsp,8
	jmp		endProg
	;printf(msjErrOpenLis)

errorOpenSel:
    mov     rdi,msjErrOpenSel
	sub		rsp,8
    call    puts
	add		rsp,8
	jmp		closeFileListado
closeFiles:
	mov		rdi,[handleSeleccion]
	sub		rsp,8
	call	fclose				
	add		rsp,8
closeFileListado:
    mov     rdi,[handleListado]
	sub		rsp,8
    call    fclose
	add		rsp,8
endProg:
ret

;------------------------------------------------------
;------------------------------------------------------
;   RUTINAS INTERNAS
;------------------------------------------------------
validarRegistro:
	mov     byte[registroValido],'N'

	sub		rsp,8
	call	validarMarca
	add		rsp,8
	cmp		byte[datoValido],'N'
	je		finValidarRegistro

	sub		rsp,8
	call	validarAnio
	add		rsp,8
	cmp		byte[datoValido],'N'
	je		finValidarRegistro

	sub		rsp,8
	call	validarPrecio
	add		rsp,8
	cmp		byte[datoValido],'N'
	je		finValidarRegistro

	mov     byte[registroValido],'S'
finValidarRegistro:
ret

;------------------------------------------------------
;VALIDAR MARCA
validarMarca:
	mov     byte[datoValido],'S'
	mov     rbx,0
	mov     rcx,4;4 porque son 4 marcas
nextMarca:
	push	rcx;apila rcx(4) y lo tiene guardado en la pila

	mov     rcx,10;recien ahi puedo usar rcx,ahora rcx = 10,cuantos bytes comparo
	lea		rsi,[marca] ;copia dir de marca en rsi
	lea		rdi,[vecMarcas + rbx]
repe cmpsb ; compara tanto bytes como lo indica rcx entre rsi,rdi
	pop		rcx;desapilo y recupero a 4 de la pila y rcx vuelve a ser 4

	je		marcaOk
	add		rbx,10
	loop	nextMarca;loop= si rcx no es igual a cero, sigo iterando
	
	mov     byte[datoValido],'N'
marcaOk:
mov	rsi,[datoValido]
sub		rsp,8
call printf_char
add		rsp,8
ret
;------------------------------------------------------
;VALIDAR AÑO
validarAnio:
	mov     byte[datoValido],'N'

	mov		rcx,4
	mov		rsi,anio
	mov		rdi,anioStr
rep	movsb;copio anio en anioStr

	mov		rdi,anioStr    
	mov		rsi,anioFormat   
	mov		rdx,anioNum      
	sub		rsp,8
	call	sscanf;scaneo a anioStr de un string a un numero y me lo guardo en anioNum
	add		rsp,8
	cmp rax,1
	jl	anioError

; Verifico si el año esta comprendido en el rango 2020 - 2022
	cmp		word[anioNum],2020
	jl		anioError
	cmp		word[anioNum],2022
	jg		anioError 

	mov		byte[datoValido],'S'
anioError:
mov	rsi,[datoValido]
sub		rsp,8
call printf_char
add		rsp,8
ret

;------------------------------------------------------
;VALIDAR PRECIO
validarPrecio:
	mov     byte[datoValido],'S'
	cmp		dword[precio],5000000
	jle		precioOk
	mov     byte[datoValido],'N'

precioOk:
mov	rsi,[datoValido]
sub		rsp,8
call printf_char
add		rsp,8
ret
;------------------------------------------------------
;PRINTF_CHAR
printf_char:
	mov		rdi,charFormat	;PRIMER PARAMETRO DE printf. El segundo se carga afuera en rsi
	sub		rsp,8
	call	printf
	add		rsp,8
ret 