global	main
extern
section		.data
section		.bss
section		.text

main:



	ret

;		nasm  idiv.asm -f elf64
;     	gcc   idiv.o  -o idiv.out -no-pie
;       ./idiv.out
;rdi rsi rcx 
;rax es el registro que siempre recibe el resultado de las funciones de C