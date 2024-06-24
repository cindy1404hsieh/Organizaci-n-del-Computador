;*******************************************************************************
; textoL.asm
; Ingresar por teclado un texto y luego un caracter e imprimir por pantalla:
;   - El texto de forma invertida
;   - La cantidad de apariciones del caracter en un texto
;   - El porcentaje de esas apariciones respecto de la longitud total del texto
;   nasm  copia_de_texto.asm -f elf64
;   gcc   copia_de_texto.o  -o copia_de_texto.out -no-pie
;   ./copia_de_texto.out
;*******************************************************************************
global  main
extern	puts
extern  gets
extern  printf

section     .data ;.data tiene que estar incializados las variables
	msjIngTexto		db	"Ingrese un texto por teclado (max 99 caracteres)",0
    msjIngCaracter  db  "ingrese un caracter: ",0
    contadorCarac   dq  0 ;q = quarter,64 bits=8 bytes. 
    longTexto       dq  0
    msjTextoInv     db  "Texto invertido: %s",10,0
    msjCantidad     db  "El caracter %c aparece %lli veces.",10,0 ;el 10 funciona como /n
    msjPorcentaje   db  "El porcentaje de aparicion es %lli %%",10,0 ;lli= int(8 bytes)

;Para debug
    msjLongTexto    db  "Longitud de texto: %lli",10,0
    
section     .bss ;.bss no tiene que estar incializados las variables, y seran ceros por default
    texto             resb 500 ; reserve byte, bufer para guardar el texto ingresado del usuario
    caracter          resb 50  ;para guardar el caracter ingresado del usuario
    textoInvertido    resb 100 ;para guardar el texto invertido

section     .text

main:
;   Ingreso texto
    mov     rdi,msjIngTexto 
    call    puts 
    mov     rdi,texto
    call    gets  
    
;   Ingreso caracter
    mov     rdi,msjIngCaracter
    call    puts
    
    mov     rdi,caracter
    call    gets
    

    mov     rsi,0
compCaracter:
    cmp     byte[texto + rsi],0
    je      finString
    inc     qword[longTexto]

    mov     al,[texto + rsi]
    cmp     al,[caracter]
    jne     sgteCarac
    inc     qword[contadorCarac]
sgteCarac:
    inc     rsi
    jmp     compCaracter
finString:

;   Invierto texto
    mov     rcx,[longTexto]
    mov     rdi,0   ;para q apunte al primer caracter de textoInvertido
copioCarac:
    cmp     rcx,0
    je      finCopia
    mov     al,[texto + rsi - 1]
    mov     [textoInvertido + rdi],al
    inc     rdi
    dec     rsi
    dec     rcx
    jmp     copioCarac
finCopia:
    mov     byte[textoInvertido + rdi],0


    mov     rdi,msjLongTexto
    mov     rsi,[longTexto]
    sub     rsp,8   ;ACOMODO EL PUNTERO A LA PILA SOLO PARA PRINTF EN LINUX
    call    printf
    add     rsp,8   ;VUELVO EL PUNTERO A LA PILA A SU VALOR ANTERIOR

;   Imprimo texto invertido
    mov     rdi,msjTextoInv
    mov     rsi,textoInvertido
    sub     rsp,8   ;ACOMODO EL PUNTERO A LA PILA SOLO PARA PRINTF EN LINUX
    call    printf
    add     rsp,8   ;VUELVO EL PUNTERO A LA PILA A SU VALOR ANTERIOR
    

;   Imprimo cantidad de apariciones del caracter
    mov     rdi,msjCantidad
    mov     rsi,[caracter]
    mov     rdx,[contadorCarac]
    sub     rsp,8   ;ACOMODO EL PUNTERO A LA PILA SOLO PARA PRINTF EN LINUX
    call    printf
    add     rsp,8   ;VUELVO EL PUNTERO A LA PILA A SU VALOR ANTERIOR
      

;   Imprimo Porcentaje
    imul    rax,[contadorCarac],100
    sub     rdx,rdx
    idiv    qword[longTexto]

    mov     rdi,msjPorcentaje
    mov     rsi,rax
    sub     rsp,8   ;ACOMODO EL PUNTERO A LA PILA SOLO PARA PRINTF EN LINUX
    call    printf
    add     rsp,8   ;VUELVO EL PUNTERO A LA PILA A SU VALOR ANTERIOR
    
ret 