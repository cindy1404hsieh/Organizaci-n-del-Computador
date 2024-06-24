global	main
extern printf
section		.data

	msj_debug db "numero en pos %li = %li",10,0
	vector times 5 dq 0 ;inicializo el vector con ceros
	posicion dq 1
	numero dq 1
	mi_rcx dq 0
	tope dq 5
	msj_rcx db "mi rcx = %li",10,0
section		.bss
section		.text

main:
agregar:
	cmp qword[tope],0
	je fin
	mov rax,[numero]

	mov rbx,[posicion]
	dec rbx
	imul rbx,8 ;8 por ser 8 bytes (pos - 1)*longElemento
	mov [vector +rbx],rax ;agrego el num al vector

	mov rdi,msj_debug
	mov rsi,[posicion]
	mov rdx,[vector +rbx]
	sub rsp,8
	call printf
	add rsp,8

	inc qword[numero]
	inc qword[posicion]

	
	mov rdi,msj_rcx
	mov rsi,[tope]
	sub rsp,8
	call printf
	add rsp,8

	dec qword[tope]
	

	
	jmp agregar
fin:
ret 