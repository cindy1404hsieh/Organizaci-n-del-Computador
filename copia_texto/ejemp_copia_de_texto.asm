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
;string = db %s
;integer = dq %lli
;caracter = d? %c
;/n = 10
;rdi rsi rcx rax
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
    mov     rdi,msjIngTexto ;copia el msjIngTexto al registro rdi
    call    puts ;puts:imprime el registro rdi (un string)hasta q se encuentre un cero y concatena /n 
        ;printf("%s\n",msjIngTexto);
    mov     rdi,texto
    call    gets  
        ;scanf(" %s",texto);
        ;texto = "koala"
;   Ingreso caracter
    mov     rdi,msjIngCaracter
    call    puts
        ;printf("%s\n",msjIngCaracter);
    mov     rdi,caracter
    call    gets
        ;scanf(" %s",caracter);
        ;caracter = "a"

    mov     rsi,0
        ;rsi = 0
compCaracter: 
    cmp     byte[texto + rsi],0
        ;if(texto[rsi(comienza en 0)] == 0){
    je      finString
            ;go to finString
        ;}
    inc     qword[longTexto] ; 'q'word= para integer
        ;else{
            ;longTexto(comienza en 0)++;
    
    mov     al,[texto + rsi]
    cmp     al,[caracter]
        ;como que no puedo comparar de memoria con memoria 
        ;(contenido del texto, un char con un char)
        ;cmp [texto + rsi], [caracter]
        ;necesito  a 'al' como un registro que nos ayude
            ;if(texto[rsi] != caracter("a")){
    jne     sgteCarac
                ;go to sgteCarac
            ;}
    inc     qword[contadorCarac]
            ;else(es decir, coinciden:texto[rsi] == "a"){ contadorCarac++(comienza en 0); }
sgteCarac:
    ;sumo al rsi para avanzar al siguiente caracter del texto
    inc     rsi
    ;rsi++
    jmp     compCaracter
    ;vuelvo al for
finString:

;   Invierto texto
;ya sali del for que: recorrio todo el texto y actualizo la longitud del texto(5) y 
;actualizo cant de caracter aparecidos(2)
    mov     rcx,[longTexto]
    ;rcx = 5
    mov     rdi,0   ;para q apunte al primer caracter de textoInvertido
    ;rdi = 0
copioCarac:
;aca rsi es como una i, es de texto
;rdi es como una j, es de textoInvertido
    cmp     rcx,0
    ;if(rcx(5) == 0){
    je      finCopia
        ;go to finCopia
    ;}
    ;lo mismo que antes, no puedo igualar textoInv[j]= texto[i]
    ;necesito un 'al' registro temporal 
    mov     al,[texto + rsi - 1] ; rsi  = 5 (rsi funciono como una i)
    ;else{
        ;al = texto[5-1]= texto[4]
    mov     [textoInvertido + rdi],al
        ;textoInvertido[rdi(comienza en 0)] = texto[4]
    inc     rdi
        ;rdi++(0+1 = 1)
    dec     rsi
        ;rsi--(5-1 = 4)
    dec     rcx
        ;rcx--(5-1 = 4)
    ;}
    jmp     copioCarac

finCopia:
    mov     byte[textoInvertido + rdi],0
    ;rdi = 4
    ;pone al final del textoInvertido un 0


;   Imprimo longitud del texto

    mov     rdi,msjLongTexto
    ;rdi = msjLongTexto = "Longitud de texto: %lli"
    mov     rsi,[longTexto]
    ;rsi = longTexto = 5
    sub     rsp,8   ;ACOMODO EL PUNTERO A LA PILA SOLO PARA PRINTF EN LINUX
    call    printf
    add     rsp,8   ;VUELVO EL PUNTERO A LA PILA A SU VALOR ANTERIOR
    ;printf("Longitud de texto: %lli",longTexto);


;   Imprimo texto invertido

    mov     rdi,msjTextoInv
    ;rdi = msjTextoInv = "Texto invertido: %s"
    mov     rsi,textoInvertido
    ;rsi = textoInvertido = "alaok"
    sub     rsp,8   ;ACOMODO EL PUNTERO A LA PILA SOLO PARA PRINTF EN LINUX
    call    printf
    add     rsp,8   ;VUELVO EL PUNTERO A LA PILA A SU VALOR ANTERIOR
    ;printf("Texto invertido: %s",textoInvertido);


;   Imprimo cantidad de apariciones del caracter

    mov     rdi,msjCantidad
    ;rdi = msjCantidad = "El caracter %c aparece %lli veces".
    mov     rsi,[caracter]
    ;rsi = caracter = "a"
    mov     rdx,[contadorCarac]
    ;rdx = contadorCarac = 2
    sub     rsp,8   ;ACOMODO EL PUNTERO A LA PILA SOLO PARA PRINTF EN LINUX
    call    printf
    add     rsp,8   ;VUELVO EL PUNTERO A LA PILA A SU VALOR ANTERIOR
    ;printf("El caracter %c aparece %lli veces",caracter,contadorCarac);

;   Imprimo Porcentaje

    imul    rax,[contadorCarac],100
    ;rax = 2 x 100 = 200
    sub     rdx,rdx
    ;??????
    idiv    qword[longTexto]
    ;rdx:rax/op
    ;resto:cociente/qword[longTexto]
    ;0:40/5

    mov     rdi,msjPorcentaje
    ;rdi = "El porcentaje de aparicion es %lli %%"
    mov     rsi,rax
    ;rsi = rax = 40
    sub     rsp,8   ;ACOMODO EL PUNTERO A LA PILA SOLO PARA PRINTF EN LINUX
    call    printf
    add     rsp,8   ;VUELVO EL PUNTERO A LA PILA A SU VALOR ANTERIOR
    ;printf("El porcentaje de aparicion es %lli %%",rsi(40%))
    ret