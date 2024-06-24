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
extern
extern
extern
extern
extern

section		.data
	listado db "listado.dat",0
	modeListado db "rb",0
	regListado 				times 0 db ''
		marca				times 10 db ' '			
	   	año de fabricacion	times 4	 db ' '	
	    patente				times 7	 db ' '	
		precio				times 4  db ' '	

	seleccion db "seleccionados.dat",0
	modeSeleccion db "wb",0
	regSeleccion			times 0 db ''
	    patenteSel			times 7	 db ' '	
		precioSel			times 4  db ' '	

	msjErrOpenLis db "no se pudo abrir listado.dat",10,0
	msjErrOpenSel db "no se pudo abrir seleccionados.dat",10,0

	vectorMarcas db "Fiat      Ford      Chevrolet Peugeot   ",0


section		.bss
	idListado resb 1
	registroValido resb 1
	idSeleccion resb 1
section		.text

main:
	mov 	rdi,listado
	mov 	rsi,modeListado
	call fopen

	cmp rax,0
	jle errorOPENLis
	mov [idListado],rax

	mov 	rdi,seleccion
	mov 	rsi,modeSeleccion
	call fopen

	cmp rax,0
	jle errorOPENSel
	mov [idSeleccion],rax


leerRegistro:
	mov rdi,regListado
	mov rsi,25
	mov rdx,1
	mov rcx,[idListado]
	call fread

	cmp rax,0
	jle closeFileSel

	call validarRegistro
	cmp byte[registroValido],'N'
	je leerRegistro

escribirRegistro:
	mov rdi,[patente]
	mov [patenteSel],rdi 

	mov rdi,[precio]
	mov [precioSel],rdi 


	mov rdi,regSeleccion
	mov rsi,11
	mov rdx,1
	mov rcx,[idSeleccion]
	call fwrite
	jmp leerRegistro

errorOpenLis:
	mov rdi,msjErrorOpenLis
	call puts 
	jmp finPrograma
errorOpenSel:
	mov rdi,msjErrorOpenSel
	call puts 
	jmp closeFileListado
closeFileSel:
	mov rdi,[idSeleccion]
	call fclose
closeFileListado:
	mov rdi,[idListado]
	call fclose
finPrograma:
ret

;rutinas internas de validacion
validarRegistro:
	mov byte[registroValido],'N'
	call validarMarca
	cmp byte[marcaValido],'N'
	je finValidarRegistro

	call validarAnio
	cmp byte[anioValido],'N'
	je finValidarRegistro

	call validarPrecio
	cmp byte[precioValido],'N'
	je finValidarRegistro

	mov byte[registroValido],'S'
finValidarRegistro:
ret
;   Marca (que sea Fiat, Ford, Chevrolet o Peugeot)
cmpsb 65
Compara el contenido de memoria apuntado por RSI
(origen/source) con el apuntado por RDI (destino/destination).
Compara tantos bytes como los indicados en el registro RCX

	. . .
	mov RCX,4
	lea RSI,[MSG1]
	lea RDI,[MSG2]

repe cmpsb
	JE IGUALES
	. . .

validarMarca:
	mov byte[marcaValido],'N'
	mov rbx,0
	mov rcx,4
	;rcx = cantidad de veces a iterar
sgteMarca:
	push rcx

	mov rcx,10
	;rcx = pos vector
	lea rsi,[marca]
	lea rdi,[vectorMarcas + rbx]
repe cmpsb

	je marcaOk
	pop rcx
	;rcx = 4
	add rbx,10

	loop sgteMarca
	call finValidarMarca
marcaOK:
	mov byte[marcaValido],'S'
finValidarMarca:
ret
;   Año (que sea un valor numérico y que este entre 2020 y 2022 (inclusive)  )

validarAnio:
	mov byte[anioValido],'N'
	mov		rcx,4
	mov		rsi,anio
	mov		rdi,anioStr
rep	movsb;copio dir de anio en anioStr

	mov		rdi,anioStr   ;anioStr db "****",0 
	mov		rsi,anioFormat ;anioFormat db "%i",0  %i 32bits=4bytes
	mov		rdx,anioNum     ;anioNum dd 0 
	sub		rsp,8
	call	sscanf;scaneo a anioStr de un string a un numero y me lo guardo en anioNum
	add		rsp,8
	cmp rax,1
	jl	finValidarAnio

; Verifico si el año esta comprendido en el rango 2020 - 2022
	cmp		dword[anioNum],2020
	jl		anioError
	cmp		dword[anioNum],2022
	jg		finValidarAnio 
	mov byte[anioValido],'S'
finValidarAnio:
ret 

;   Precio que sea un valor numerico y cuyo precio sea inferior a 5.000.000$)
validarPrecio:
	mov byte[precioValido],'N'
	mov		rcx,4
	mov		rsi,precio
	mov		rdi,precioStr
rep	movsb;copio dir de precio en precioStr

	mov		rdi,precioStr   ;precioStr db "****",0 
	mov		rsi,precioFormat ;precioFormat db "%i",0  %i 32bits=4bytes
	mov		rdx,precioNum     ;precioNum dd 0 
	sub		rsp,8
	call	sscanf;scaneo a precioStr de un string a un numero y me lo guardo en precioNum
	add		rsp,8
	cmp rax,1
	jl	finValidarprecio

; Verifico si el precio sea inferior a 5.000.000$
	cmp		dword[precioNum],5.000.000
	jge		finValidarPrecio
	mov byte[precioValido],'S'

finValidarPrecio:
ret 