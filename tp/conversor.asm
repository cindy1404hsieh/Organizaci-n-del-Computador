;***************************************************************************
; 1)ingresar configuraciones hexadecimal o binarias de numeros almacenados en formato IEEE 
; 754 de presicion simple e imprima su notacion cientifica normalizada en base 2
;(Ej +1,110101 x 10^101)
; 2)ingresar notacion cientifica normalizada en base 2 y visualizar su 
; configuraciones hexadecimal o binarias de dicho numero almacenado 
; en formato IEEE 754 de presicion simple
;***************************************************************************
global	main
extern puts 
extern gets
extern printf

section		.data
	msj_pedir_input db "Ingrese 'c' para convertir configuraciones hexadecimal/binarias de numeros almacenados en formato IEEE 754 de presicion simple a su notacion cientifica normalizada en base 2(ejemplo: 01000010100011101000000000000000 o 428E8000)",10,0 
	msj_pedir_input2 db "o 'n' para convertir notacion cientifica normalizada en base 2 a su configuracion hexadecimal/binaria de dicho numero almacenado  en formato IEEE 754 de presicion simple (ejemplo: +1,00011101x10^110):",10,0

	msj_pedir_base db "Ingrese la base de la configuracion hexadecimal o binaria(h o b) con que queres trabajar:",10,0
	msj_pedir_num db "y el numero a convertir:",10,0

;***************************C O N F I G U R A C I O N***********************************************************
	
	vector_exp_a_invertir dq 0,0,0,0,0,0,0,0,0,0 ; no se cuantos son

	tope_vector dq 1
	tope_vector_invertido dq 1
	vector_invertido dq 0,0,0,0,0,0,0,0,0,0
	msjImprimirNotacion db "Notacion cientifica: %s1,%sx10^",0
	msj_exponente db "%li",0
	msj_enter db "",10,0

	posicion dq 1

	msjImprimirNumeroStr32 db "Hexadecimal expresada en binaria: %s",10,0
;*********************************N O T A C I O N***********************************************************
	
	notacionStr times 50 db '?'

	pos_exponente dq 3
	configStr32 times 32 db '0'
	pos_mantisa_config dq 9
	exponente_extraido times 10 db '0'
	tope_exponente_extraido dq 0

	pos_exponente_config dq 8
	
	msj_imprimir_resultado_configStr8 db "Configuracion Hexadecimal: %s",10,0
	

	msj_imprimir_resultado_configStr32 db "Configuracion Binaria: %s",10,0

	
section		.bss
	signo resb 20
	exponente resb 20 
	mantisa resb 30

	input resb 1
	input_valido resb 1
	base resb 1
	base_valido resb 1
	numeroStr resb 100
	numeroStr32 resb 100

	signoImprimir resb 20
	exponenteImprimir resb 20

	pos_aux resq 1
	sum_aux resq 1
	resto resq 1
	cociente resq 1
	dividendo resq 1
	
	configStr8 resb 10
	
	
section		.text

main:
;********************************************************************************************
;********************************************************************************************
pedir_input:
	mov rdi,msj_pedir_input
	sub rsp,8
	call puts
	add rsp,8 
	mov rdi,msj_pedir_input2
	sub rsp,8
	call puts
	add rsp,8 

	mov rdi,input 
	sub rsp,8
	call gets
	add rsp,8 
	call validar_input
	cmp byte[input_valido],'N'
	je pedir_input
;********************************************************************************************
;********************************************************************************************
	
pedir_base:
	mov rdi,msj_pedir_base
	sub rsp,8
	call puts
	add rsp,8 

	mov rdi,base
	sub rsp,8
	call gets
	add rsp,8 
	call validar_base
	cmp byte[base_valido],'N'
	je pedir_base
;********************************************************************************************
;********************************************************************************************
;empiezo con B/H->notacion
pedir_numero:
	mov rdi,msj_pedir_num
	sub rsp,8
	call puts
	add rsp,8 

	mov rdi,numeroStr
	sub rsp,8
	call gets
	add rsp,8 

	
	cmp byte[input],'c'
	je configuracion

	cmp byte[input],'n'
	je notacion
;********************************************************************************************
;********************************************************************************************
configuracion:
	cmp byte[base],'h'
	je hexa_paso_binaria

	cmp byte[base],'b'
	
	je pasar_string_a_string32

;********************************************************************************************
;********************************************************************************************
hexa_paso_binaria:
;el numero sera de 8 digitos
;paso 16->2 cada digito=4 digitos
	mov rcx,8
	mov rbx,0
	mov r8,0
moverSgteDigito:
	cmp rcx,0
	je fin_hexa_paso_binaria
	cmp byte[numeroStr + rbx],'0'
	je cero_h_b 
	cmp byte[numeroStr + rbx],'1'
	je uno_h_b
	cmp byte[numeroStr + rbx],'2'
	je dos_h_b
	cmp byte[numeroStr + rbx],'3'
	je tres_h_b
	cmp byte[numeroStr + rbx],'4'
	je cuatro_h_b
	cmp byte[numeroStr + rbx],'5'
	je cinco_h_b
	cmp byte[numeroStr + rbx],'6'
	je seis_h_b
	cmp byte[numeroStr + rbx],'7'
	je siete_h_b
	cmp byte[numeroStr + rbx],'8'
	je ocho_h_b
	cmp byte[numeroStr + rbx],'9'
	je nueve_h_b
	cmp byte[numeroStr + rbx],'A'
	je a_h_b
	cmp byte[numeroStr + rbx],'B'
	je be_h_b
	cmp byte[numeroStr + rbx],'C'
	je ce_h_b
	cmp byte[numeroStr + rbx],'D'
	je de_h_b
	cmp byte[numeroStr + rbx],'E'
	je e_h_b
	cmp byte[numeroStr + rbx],'F'
	je efe_h_b

cero_h_b:
	mov dword[numeroStr32 + r8],'0000'
	jmp fin_asignacion
uno_h_b:
	mov dword[numeroStr32 + r8],'0001'
	jmp fin_asignacion
dos_h_b:
	mov dword[numeroStr32 + r8],'0010'
	jmp fin_asignacion
tres_h_b:
	mov dword[numeroStr32 + r8],'0011'
	jmp fin_asignacion
cuatro_h_b:
	mov dword[numeroStr32 + r8],'0100'
	jmp fin_asignacion
cinco_h_b:
	mov dword[numeroStr32 + r8],'0101'
	jmp fin_asignacion
seis_h_b:
	mov dword[numeroStr32 + r8],'0110'
	jmp fin_asignacion
siete_h_b:
	mov dword[numeroStr32 + r8],'0111'
	jmp fin_asignacion
ocho_h_b:
	mov dword[numeroStr32 + r8],'1000'
	jmp fin_asignacion
nueve_h_b:
	mov dword[numeroStr32 + r8],'1001'
	jmp fin_asignacion
a_h_b:
	mov dword[numeroStr32 + r8],'1010'
	jmp fin_asignacion
be_h_b:
	mov dword[numeroStr32 + r8],'1011'
	jmp fin_asignacion
ce_h_b:
	mov dword[numeroStr32 + r8],'1100'
	jmp fin_asignacion
de_h_b:
	mov dword[numeroStr32 + r8],'1101'
	jmp fin_asignacion
e_h_b:
	mov dword[numeroStr32 + r8],'1110'
	jmp fin_asignacion
efe_h_b:
	mov dword[numeroStr32 + r8],'1111'
	jmp fin_asignacion

fin_asignacion:
	add r8,4
	inc rbx
	dec rcx
	jmp moverSgteDigito

fin_hexa_paso_binaria:

	mov rdi,msjImprimirNumeroStr32
	mov rsi,numeroStr32
	sub rsp,8
	call printf
	add rsp,8

	jmp pasar_numero_a_notacion 

;********************************************************************************************
;********************************************************************************************
pasar_string_a_string32:
	mov rcx,32
	lea rsi,[numeroStr]
	lea rdi,[numeroStr32]

rep movsb	
;********************************************************************************************
;********************************************************************************************
pasar_numero_a_notacion: 
;asumo que ya vienen como string binarias de 32 bits
	

	mov rbx,0
	mov rcx,1
	lea rsi,[numeroStr32 + rbx]
	lea rdi,[signo] ;los separo en signo,exp y mantisa
rep movsb

	mov rbx,1
	mov rcx,8
	lea rsi,[numeroStr32 + rbx]
	lea rdi,[exponente] ;los separo en signo,exp y mantisa
rep movsb

	mov rbx,9
	mov rcx,23
	lea rsi,[numeroStr32 + rbx]
	lea rdi,[mantisa] ;los separo en signo,exp y mantisa
rep movsb

;********************************************************************************************
;********************************************************************************************
operar_signo:
	cmp byte[signo],'1'
	je negativo
	cmp byte[signo],'0'
	je positivo
negativo:
	mov byte[signoImprimir],'-'
	jmp fin_operar_signo
positivo:
	mov byte[signoImprimir],'+'
fin_operar_signo:
;********************************************************************************************
;********************************************************************************************
operar_exponente:
;1.paso a base 10
;2.resto 127
;3.paso a base 2

;********************************************************************************************
;********************************************************************************************
pasar_base_2_a_10:
;asumo que hay 8 bits no mas

	mov qword[pos_aux],7
	mov qword[sum_aux],0
	mov rbx,0

	mov rcx,8 ;itero los 8 bits
moverSgteExponente:
;*************************************
	cmp rcx,0
	je fin_pasar_base_2_a_10
	push rcx ;pila: rcx = 8 , rcx ahora esta libre.
	
multiplicacion_sucesiva:
	cmp byte[exponente +rbx],'1'
	je multiplicar_nro1

	;si no jump, es un cero
	jmp fin_multiplicacion_sucesiva
multiplicar_nro1:
	mov rax,1

	mov rcx,[pos_aux] ;rcx == pos (3)
multiplicar_por_2:
	;^^^^^^^^^^^^^^^^^^^^^^^
	cmp rcx,0
	je calcular_sumatoria

	imul rax,2
	dec rcx
	;^^^^^^^^^^^^^^^^^^^^^^^
	jmp multiplicar_por_2
	
calcular_sumatoria:
	;rax = 128
	;sum_aux += mul_aux
	add [sum_aux],rax ;sum_aux = sum_aux+rax
	
fin_multiplicacion_sucesiva:

	
	dec qword[pos_aux] ;pos--
	inc rbx ;rbx++
	pop rcx ;desapilo: rcx = 8
	dec rcx

;**********************************
	jmp moverSgteExponente

fin_pasar_base_2_a_10:

	sub qword[sum_aux],127

	
;********************************************************************************************
;********************************************************************************************
;ya tengo el exp-127,ahora paso el resultado a base 2
;1,paso sum_aux a base 2 (division_sucesiva) y me lo guardo en un vector de numeros
;2,invierto el vector
;
pasar_base_10_a_2:
	mov rsi,1 ;el indice del vector
	
	mov rax,[sum_aux] ;dividendo = sum_aux
	mov [cociente],rax
	mov rbx,2

;********************************************************************************************
;********************************************************************************************
division_sucesiva:
	cmp qword[cociente],2
	jl fin_div_suc

	mov rax,[cociente]
	mov rdx,0
	idiv rbx ;rbx = 2
	mov [resto],rdx
	mov [cociente],rax
	;cociente rax=7
	;resto rdx=1
	
	;(tope_vector-1)*longElem
	mov r8,[tope_vector] ;tope=1
	dec r8 
	imul r8,8 ;8bytes
	mov rcx,[resto]
	mov [vector_exp_a_invertir + r8],rcx ;agregar el resto a mi vector a invertir


	inc qword[tope_vector] ;tope=1, tope =2
	jmp division_sucesiva

fin_div_suc:	
	;si es < 2, agrego el dividendo a mi vector
	;(tope_vector-1)*longElem
	mov r8,[tope_vector] ;tope=4
	dec r8 
	imul r8,8
	mov rax,[cociente]
	mov [vector_exp_a_invertir + r8],rax

;********************************************************************************************
;********************************************************************************************
invertir_vector:
	

copioNumero:
    cmp     qword[tope_vector],0
    je      finCopia

    mov r8,[tope_vector]
    dec r8 
    imul r8,8 ;r8 = apunta el ult elemento

    mov r9,[tope_vector_invertido]
    dec r9
    imul r9,8 ;r9 = apunta el primer posicion

    mov     rax,[vector_exp_a_invertir + r8]
    mov     [vector_invertido + r9],rax


    inc qword[posicion]
    inc qword[tope_vector_invertido]
    dec qword[tope_vector] ;long vector--
    jmp copioNumero
finCopia:
	sub qword[tope_vector_invertido],1

;********************************************************************************************
;********************************************************************************************
	

imprimir_resultado_notacion:
	
	mov rdi,msjImprimirNotacion
	mov rsi,signoImprimir
	mov rdx,mantisa
	sub rsp,8
	call printf
	add rsp,8

	mov qword[posicion],1
imprimir_exponente:
    cmp     qword[tope_vector_invertido],0
    je      fin_imprimir_exponente

    mov r9,[posicion]
    dec r9
    imul r9,8 ;r9 = apunta el primer posicion


	mov rdi,msj_exponente
	mov rsi,[vector_invertido + r9]
	sub rsp,8
	call printf
	add rsp,8

    inc qword[posicion]
    dec qword[tope_vector_invertido] ;long vector--
    jmp imprimir_exponente
fin_imprimir_exponente:
	mov rdi,msj_enter
	sub rsp,8
	call puts
	add rsp,8
	jmp fin_programa
;********************************************************************************************
;********************************************************************************************
;********************************************************************************************
;********************************************************************************************
notacion:
;ejemplo numeroStr: +1,00011101x10^110
pasar_string_a_notacionStr:
	
	mov rcx,50
	lea rsi,[numeroStr]
	lea rdi,[notacionStr]
rep movsb

;********************************************************************************************
;********************************************************************************************	
extraer_signo:
	cmp byte[notacionStr],'+'
	je asignar_cero

	cmp byte[notacionStr],'-'
	je asignar_uno
asignar_cero:
	mov byte[configStr32],'0'
	jmp extraer_mantisa
asignar_uno:
	mov byte[configStr32],'1'
	jmp extraer_mantisa
;********************************************************************************************
;********************************************************************************************
extraer_mantisa:

	mov ebx,[pos_exponente]
	mov ecx,[pos_mantisa_config] 
	
moverSgteMantisa:
	mov ebx,[pos_exponente]
	mov ecx,[pos_mantisa_config]

	cmp byte[notacionStr + ebx],'x'
	je fin_extraer_mantisa

	mov al,[notacionStr + ebx]
	mov [configStr32 + ecx ],al
 
 	;mov rdi,msj_debug_numero_en_configstr32
	;mov rsi,[pos_exponente]
	;mov rdx,[configStr32 + ecx ]
	;sub rsp,8
	;call printf
	;add rsp,8

	inc qword[pos_mantisa_config] 
	inc qword[pos_exponente]

	jmp moverSgteMantisa

fin_extraer_mantisa:
	add qword[pos_exponente],4

	
;********************************************************************************************
;********************************************************************************************
extraer_exponente:
	mov ebx,[pos_exponente] 
	mov ecx,[tope_exponente_extraido] ;tope = 0
moverSgteExponenteStr:
	mov ebx,[pos_exponente]
	mov ecx,[tope_exponente_extraido]

	cmp byte[notacionStr + ebx],byte 0

	je fin_extraer_exponente

	mov al,[notacionStr + ebx]
	mov [exponente_extraido + ecx ],al


	inc qword[pos_exponente]
	inc qword[tope_exponente_extraido]

	jmp moverSgteExponenteStr
fin_extraer_exponente:	
	
	
pasar_base_2_a_10_extraido:
;asumo que hay 8 bits no mas
	mov r8,[tope_exponente_extraido]
	dec r8
	mov [pos_aux],r8
	mov qword[sum_aux],0
	mov rbx,0
;hacer todo con jpm para evitar problemas

	mov rcx,[tope_exponente_extraido] ;itero los 8 bits
moverSgteExponente_e:
;*************************************
	cmp rcx,0
	je fin_pasar_base_2_a_10_extraido
	push rcx ;pila: rcx = 8 , rcx ahora esta libre.
	
multiplicacion_sucesiva_e:
	cmp byte[exponente_extraido +rbx],'1'
	je multiplicar_nro1_e

	;si no jump, es un cero
	jmp fin_multiplicacion_sucesiva_e
multiplicar_nro1_e:
	mov rax,1

	mov rcx,[pos_aux] ;rcx == pos (3)
multiplicar_por_2_e:
	;^^^^^^^^^^^^^^^^^^^^^^^
	cmp rcx,0
	je calcular_sumatoria_e

	imul rax,2
	dec rcx
	;^^^^^^^^^^^^^^^^^^^^^^^
	jmp multiplicar_por_2_e
	
calcular_sumatoria_e:
	;rax = 128
	;sum_aux += mul_aux
	add [sum_aux],rax ;sum_aux = sum_aux+rax
	
fin_multiplicacion_sucesiva_e:

	
	dec qword[pos_aux] ;pos--
	inc rbx ;rbx++
	pop rcx ;desapilo: rcx = 8
	dec rcx

;**********************************
	jmp moverSgteExponente_e

fin_pasar_base_2_a_10_extraido:

sumar_127:
	add qword[sum_aux],127

;********************************************************************************************
;********************************************************************************************

pasar_base_10_a_2_e:
	mov rsi,1 ;el indice del vector
	
	mov rax,[sum_aux] ;dividendo = sum_aux
	mov [cociente],rax
	mov rbx,2
	mov ecx,[pos_exponente_config] ;=8 ultima pos del exponente en configStr32
;********************************************************************************************
;********************************************************************************************
division_sucesiva_e:
	cmp qword[cociente],2
	jl fin_div_suc_e

	mov rax,[cociente] ;seteos antes de idiv
	mov rdx,0  			;seteos antes de idiv
	idiv rbx ;rbx = 2
	mov [resto],rdx
	mov [cociente],rax
	;cociente rax=7
	;resto rdx=1

	mov ecx,[pos_exponente_config]
	cmp qword[resto],0
	je resto_es_cero

	cmp qword[resto],1
	je resto_es_uno

resto_es_cero:
	mov byte[configStr32 + ecx],'0'
	jmp fin_asignar_resto
resto_es_uno:
	mov byte[configStr32 + ecx],'1'
	jmp fin_asignar_resto
fin_asignar_resto:
	
	dec qword[pos_exponente_config] ;8-1=7
	jmp division_sucesiva_e

fin_div_suc_e:
	;si es < 2, agrego el dividendo a mi vector

	mov ecx,[pos_exponente_config]
	cmp qword[cociente],1
	je cociente_es_uno

	jmp fin_asignar_cociente
cociente_es_uno:

	mov byte[configStr32 + ecx],'1'
	jmp fin_asignar_cociente

fin_asignar_cociente:

;********************************************************************************************
;********************************************************************************************
	cmp byte[base],'h'
	je binaria_paso_hexa
	jmp imprimir_resultado_configuracion32
binaria_paso_hexa:
;el numero sera de 32 digitos
;paso 2->16 cada 4 digitos = 1 digito
	mov rcx,8

	mov rbx,0
	mov r8,0
moverSgteDigito_b_h:
	cmp rcx,0
	je fin_binaria_paso_hexa
	cmp dword[configStr32 + rbx],'0000'
	je cero_b_h 
	cmp dword[configStr32 + rbx],'0001'
	je uno_b_h
	cmp dword[configStr32 + rbx],'0010'
	je dos_b_h
	cmp dword[configStr32 + rbx],'0011'
	je tres_b_h
	cmp dword[configStr32 + rbx],'0100'
	je cuatro_b_h
	cmp dword[configStr32 + rbx],'0101'
	je cinco_b_h
	cmp dword[configStr32 + rbx],'0110'
	je seis_b_h
	cmp dword[configStr32 + rbx],'0111'
	je siete_b_h
	cmp dword[configStr32 + rbx],'1000'
	je ocho_b_h
	cmp dword[configStr32 + rbx],'1001'
	je nueve_b_h
	cmp dword[configStr32 + rbx],'1010'
	je a_b_h
	cmp dword[configStr32 + rbx],'1011'
	je be_b_h
	cmp dword[configStr32 + rbx],'1100'
	je ce_b_h
	cmp dword[configStr32 + rbx],'1101'
	je de_b_h
	cmp dword[configStr32 + rbx],'1110'
	je e_b_h
	cmp dword[configStr32 + rbx],'1111'
	je efe_b_h

cero_b_h:
	mov dword[configStr8 + r8],'0'
	jmp fin_asignacion_b_h
uno_b_h:
	mov dword[configStr8 + r8],'1'
	jmp fin_asignacion_b_h
dos_b_h:
	mov dword[configStr8 + r8],'2'
	jmp fin_asignacion_b_h
tres_b_h:
	mov dword[configStr8 + r8],'3'
	jmp fin_asignacion_b_h
cuatro_b_h:
	mov dword[configStr8 + r8],'4'
	jmp fin_asignacion_b_h
cinco_b_h:
	mov dword[configStr8 + r8],'5'
	jmp fin_asignacion_b_h
seis_b_h:
	mov dword[configStr8 + r8],'6'
	jmp fin_asignacion_b_h
siete_b_h:
	mov dword[configStr8 + r8],'7'
	jmp fin_asignacion_b_h
ocho_b_h:
	mov dword[configStr8 + r8],'8'
	jmp fin_asignacion_b_h
nueve_b_h:
	mov dword[configStr8 + r8],'9'
	jmp fin_asignacion_b_h
a_b_h:
	mov dword[configStr8 + r8],'A'
	jmp fin_asignacion_b_h
be_b_h:
	mov dword[configStr8 + r8],'B'
	jmp fin_asignacion_b_h
ce_b_h:
	mov dword[configStr8 + r8],'C'
	jmp fin_asignacion_b_h
de_b_h:
	mov dword[configStr8 + r8],'D'
	jmp fin_asignacion_b_h
e_b_h:
	mov dword[configStr8 + r8],'E'
	jmp fin_asignacion_b_h
efe_b_h:
	mov dword[configStr8 + r8],'F'
	jmp fin_asignacion_b_h

fin_asignacion_b_h:
	add rbx,4
	inc r8
	dec rcx
	jmp moverSgteDigito_b_h

fin_binaria_paso_hexa:
	mov rdi,msj_imprimir_resultado_configStr8
	mov rsi,configStr8
	sub rsp,8
	call printf
	add rsp,8
;********************************************************************************************
;********************************************************************************************
imprimir_resultado_configuracion32:
	mov rdi,msj_imprimir_resultado_configStr32
	mov rsi,configStr32
	sub rsp,8
	call printf
	add rsp,8
;********************************************************************************************
;********************************************************************************************
fin_programa:
ret ;aca termina mi main

;*********************************
;VALIDACION INTERNA
;*********************************

validar_input:
	mov byte[input_valido],'N'
	cmp byte[input],'c'
	je es_input_valido
	
	cmp byte[input],'n'
	je es_input_valido

	jmp fin_validar_input
es_input_valido:
	mov byte[input_valido],'S'
fin_validar_input:
ret 


validar_base:
	mov byte[base_valido],'N'
	cmp byte[base],'b'
	je es_base_valido
	
	cmp byte[base],'h'
	je es_base_valido

	jmp fin_validar_base
es_base_valido:
	mov byte[base_valido],'S'
fin_validar_base:
ret 