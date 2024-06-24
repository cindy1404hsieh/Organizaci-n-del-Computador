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
extern sscanf

section		.data
	msj_pedir_input db "Ingrese 'C' para convertir configuraciones hexadecimal/binarias de numeros almacenados en formato IEEE 754 de presicion simple a su notacion cientifica normalizada en base 2:",10,0 
	msj_pedir_input2 db "o 'N' para convertir notacion cientifica normalizada en base 2 a su configuracion hexadecimal/binaria de dicho numero almacenado  en formato IEEE 754 de presicion simple:",10,0

	msj_pedir_base db "Ingrese la base de la configuracion hexadecimal o binaria(H o B) con que queres trabajar:",10,0
	msj_pedir_num db "y el numero a convertir:",10,0

	numFormatBase10 db "%i",0 ;número entero con signo base 10  32 bits
	numFormatBase16 db "%x",0 ;base 16 , 32 bits
	;numero_hexa dd 0  = 00 00 00 00 00 00 00 00 ;dword 4 bytes = 32 bits
	;1234ABCD
	;pruebaPrintFormat16 db "BASE 10 A BASE 16: %x",10,0

	
	;expFormat db "%hhi",0
	;expNumero db 0

	;vector_exp_a_invertir dw 10 dup (?) ; no se cuantos son
	vector_exp_a_invertir dq 0,0,0,0,0,0,0,0,0,0 ; no se cuantos son
	long_vector dq 0
	posicion dq 1
	vector_invertido dq 0,0,0,0,0,0,0,0,0,0
	msjImprimirNotacion db "Notacion cientifica: %c1,%s x10^ %s",10,0

	msj_debug db "tu vector de exponente(invertido):",0
	msj_debug_formato db "%li",0
	msj_debug_formato_127 db "TU NUMERO -127 BASE 10 : %li",0
	msj_hola db "hola",10
	msj_debug_reg db "SIGNO %s ,e %s ,mantisa %s ",10,0
	msj_debug_32 db "STR 32: %s ",10,0



section		.bss
	signo resb 5
	exponente resb 20 
	mantisa resb 30

	input resb 1
	input_valido resb 1
	base resb 1
	base_valido resb 1
	numeroStr resb 100
	numeroStr32 resb 100

	signoImprimir resb 1
	exponenteImprimir resb 5

	pos_aux resq 1
	mul_aux resq 1
	sum_aux resq 1

	 
section		.text

main:
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

	
	cmp byte[input],'C'
	call configuracion

	;cmp byte[input],'N'
	;je notacion


ret ;aca termina mi main

;*********************************
;VALIDACION INTERNA
;*********************************

validar_input:
	mov byte[input_valido],'N'
	cmp byte[input],'C'
	je es_input_valido
	
	cmp byte[input],'N'
	je es_input_valido

	jmp fin_validar_input
es_input_valido:
	mov byte[input_valido],'S'
fin_validar_input:
ret 


validar_base:
	mov byte[base_valido],'N'
	cmp byte[base],'B'
	je es_base_valido
	
	cmp byte[base],'H'
	je es_base_valido

	jmp fin_validar_base
es_base_valido:
	mov byte[base_valido],'S'
fin_validar_base:
ret 

configuracion:
	cmp byte[base],'H'
	;je hexa_paso_binaria

	cmp byte[base],'B'
	
	je pasar_string_a_string32

pasar_string_a_string32:
	mov rcx,32
	lea rsi,[numeroStr]
	lea rdi,[numeroStr32]

rep movsb	

	

	call pasar_numero_a_notacion

ret 
;el numero sera de 8 digitos
;paso 16->2 cada digito=4 digitos
;hexa_paso_binaria:
	;mov rcx,8
	;mov rbx,0
;moverSgteDigito:
	;call 16 ifs(aparte)
	;mov [numeroStr32 + rbx],1001
	;add rbx,4
	;loop moverSgteDigito
;ret 

;16_ifs(aparte):
;0 0000
;1 0001
;2 0010
;3 0011
;..
;ret 



 







pasar_numero_a_notacion: 
;asumo que ya vienen como string binarias de 32 bits
	
	mov rcx,1
copiar_signo:
	mov rbx,0
	mov al,[numeroStr + rbx]
	mov [signo],al ;los separo en signo,exp y mantisa
	loop copiar_signo
	

	mov rbx,1
	mov rcx,8
	lea rsi,[numeroStr + rbx]
	lea rdi,[exponente] ;los separo en signo,exp y mantisa
rep movsb

	mov rbx,9
	mov rcx,6
	lea rsi,[numeroStr + rbx]
	lea rdi,[mantisa] ;los separo en signo,exp y mantisa
rep movsb
	
	mov rdi,msj_debug_reg
	mov rsi,signo
	mov rdx,exponente
	mov rcx,mantisa
	sub rsp,8
	call printf
	add rsp,8

	call operar_signo

	

	call operar_exponente
	;call operar_mantisa
ret 

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
ret 






operar_exponente:
;1.paso a base 10
;2.resto 127
;3.paso a base 2


	

	call pasar_base_2_a_10

	

	sub qword[sum_aux],127
	;mov rdi,msj_hola
	;sub rsp,8
	;call puts
	;add rsp,8
	mov rdi,msj_debug_formato_127
	mov rsi,[sum_aux]

	sub rsp,8
	call printf
	add rsp,8
	

	call pasar_base_10_a_2
	mov rdi,msj_debug
	sub rsp,8
	call puts
	add rsp,8
	mov rbx,0
	mov rcx,[long_vector]
imprimir_debug:

	mov rdi,msj_debug_formato
	mov rsi,[vector_invertido + rbx]

	sub rsp,8
	call printf
	add rsp,8

	add rbx,8
	;loop imprimir_debug
	;mov rdi,exponente
	;mov rsi,expFormat
	;mov rdx,expNumero
	;sub		rsp,8
	;call sscanf
	;add		rsp,8
	
ret 


pasar_base_2_a_10:
;asumo que hay 8 bits no mas

	mov qword[pos_aux],7
	mov qword[mul_aux],1
	mov qword[sum_aux],0
	mov rbx,0
	mov rcx,8 ;itero los 8 bits
	

moverSgteExponente:
	push rcx ;pila rcx = 8 , rcx ahora esta libre.
;*************************************
multiplicacion_sucesiva:
	cmp byte[numeroStr32 +rbx],'1'
	je multiplicar_nro1

	;si no jump, es un cero
	jmp fin_multiplicacion_sucesiva
multiplicar_nro1:
	mov rax,[mul_aux]
	mov rcx,[pos_aux] ;rcx == pos (3)
multiplicar_por_2:
	imul rax,2
	loop multiplicar_por_2

	mov rax,[mul_aux] ;rax = mul_aux
	add [sum_aux],rax ;sum_aux = sum_aux+mul_aux
fin_multiplicacion_sucesiva:

	mov qword[mul_aux],1;resetear mul a 1
	dec qword[pos_aux] ;pos--
	inc rbx ;rbx++
	pop rcx ;desapilo rcx = 8



;**********************************
	loop moverSgteExponente


ret 





pasar_base_10_a_2:
	mov rsi,1
	mov rax,[sum_aux] ;dividendo = sum_aux
	mov rbx,2
division_sucesiva:
	idiv rbx
	;cociente rax 
	;resto rdx
	mov rbx,rax ; ahora mi dividendo=cociente

	;(posicion-1)*longElem
	mov rsi,[posicion] ;pos=1
	dec rsi 
	imul rdi,rsi,8 ;8bytes
	mov [vector_exp_a_invertir + rdi],rdx ;agregar el resto a mi vector a invertir

	inc qword[posicion] 
	inc qword[long_vector]
	cmp rbx,2 				;si mi dividendo es menor a 2 no sigo iterando
	jge division_sucesiva
	;(posicion-1)*longElem
	mov rsi,[posicion] ;pos=5
	dec rsi 
	imul rdi,rsi,8
	mov [vector_exp_a_invertir + rdi],rbx
invertir_vector:
	;   Invierto texto
    mov rcx,[long_vector]
    mov rsi,0   ;para q apunte al primer caracter de textoInvertido
    
copioNumero:
    cmp     rcx,0
    je      finCopia
    mov     rax,[vector_exp_a_invertir + rdi]
    mov     [vector_invertido + rsi],rax
    add     rsi,8 ;j++ (invertido)
    sub     rdi,8 ;i-- (original)
    dec     rcx ;long vector--
    jmp     copioNumero
finCopia:
    
	

ret 









 











