registros 4 
rsi : Source
operaciones de manejo de cadenas para apuntar al operando “origen”
 
rdi :Destination
operaciones de manejo de cadenas para apuntar al operando “destino”

rax :Acumulador
operando de instrucciones aritméticas y lógicas

rbx Base
direccionamiento de operandos

rcx :Contador
operaciones aritméticas o de string

rdx :Data
operaciones que requieren duplas de registros

section .data
db byte 1 byte (strings)
dw word 2 bytes
dd double 4 bytes
dq quad 8 bytes(numeros)
dt ten 10 bytes
section .bss
resb 
resw
resd
resq
rest 
mov copia el valor del 2do operando al 1er operando 28
mov reg,reg    
mov reg,[variable]
mov [variable],reg
mov reg,7
mov byte[variable],7

cmp 31
cmp reg,reg
cmp reg,[variable]
cmp [variable],reg
cmp reg,7
cmp byte[variable],7

jump 33
jmp funcion 
je es igual
jne no es igual
jz es cero
jnz no es cero
jg mayor
jge mayor igual
jl menor
jle menor igual
jng no mayor
jnge no mayor igual
jnl no menor
jnle no menor igual

add suma ambos y deja el resultado en el 1ro 37
add reg,reg
add reg,[variable]
add [variable],reg
add reg,7
add byte[variable],7

sub resta ambos y deja el resultado en el 1ro 39
sub reg,reg
sub reg,[variable]
sub [variable],reg
sub reg,7
sub byte[variable],7

inc suma uno al operando 41
dec resta uno al operando
inc /dec reg
inc /dec qword[variable]

imul con signo deja resultado en rax 42
mul sin signo
imul reg
imul dword[variable]

almacena resultado en el primero
imul reg,7
imul reg,reg
imul reg,word[variable]

deja resultado en el 1er operando
imul reg,reg,7
imul reg,qword[variable],7

idiv resto en dx y cociente en ax 48
div sin signo

idiv dividendo
idiv reg 
idiv byte[variable]

ejemplo: quiero hacer 21 dividido 5, me debe quedar cociente 4 y resto 1
resto dq 0 ;importante
mov rdx,0 ;importante
mov rax,21
mov rbx,5
idiv rbx ;rax = 4, rdx=1
mov [resto],rdx ;importante
idiv dividendo


conversion  50
cbw Convierte el byte almacenado en AL a una word en AX.
cwd Convierte la word almacenada en AX a una double-word en DX:AX
cwde Convierte la word almacenada en AX a una double-word en EAX
cdqe Convierte la doble-word almacenada en EAX a una quad-word en RAX

neg op 51
Realiza el complemento a 2 del operando, es decir, le cambia el signo.
neg reg
neg byte[variable]

loop op 53
Resta 1 al contenido del registro RCX y si el resultado es 0, bifurca al
punto indicado por el operando, sino continua la ejecución en la
instrucción siguiente.

  mov rcx,5
inicio: 
  ...
  ...
  loop inicio 
...

call op 54
Almacena en la pila la dirección de la instrucción siguiente a la call y bifurca
al punto indicado por el operando.
ret
Toma el elemento del tope de la pila que debe ser una dirección de
memoria (generalmente cargada por una call) y bifurca hacia la misma.

call rutina (linea 114)
	...
	...
rutina:
...
...
ret (linea 112)

tablas 55
tabla times 40 resb 1
vector times 10 resw 1
matriz times 25 db "*"

Posicionamiento en el elemento i de un vector
(i - 1) * longitudElemento

Posicionamiento en el elemento i,j de una matriz
(i-1)*longitudFila + (j-1)*longitudElemento

longitdFila= longitudElemento*cantidadColumnas
;rbx = [(fila-1) * longElem * cantCol] + [(columna-1) * longElem]
and op1,op2 58
or op1,op2 59
xor op1,op2 60
not  op 61

lea op1,op2 62
Copia en el operando 1 (un registro) la dirección de memoria del
operando 2.

lea reg,[variable]
es lo mismo que
mov reg,variable

movsb 63
Copia el contenido de memoria apuntado por RSI (origen/source)
al apuntado por RDI (destino/destination). Copia tantos bytes
como los indicados en el registro RCX

	. . .
	mov RCX,4
	lea RSI,[msjORINAL]
	lea RDI,[msjDESTINO]

rep movsb

	. . .
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

push op 66
Inserta el operando (de 64 bits) en la pila. Decrementa (resta 1)
el contenido del registro RSP
pop op
Elimina el último elemento insertado en la pila (de 64 bits) y lo
copia en el operando. Incrementa (suma 1) al contenido del
registro RSP

push /pop reg
push /pop qword[variable]

ejemplo 
validarMarca:
	mov     byte[datoValido],'S'
	mov     rbx,0
	mov     rcx,4;4 porque son 4 marcas
nextMarca:
	push	rcx;apila rcx(4) y lo tiene guardado en la pila

	mov     rcx,10;recien ahi puedo usar rcx,ahora rcx = 10
	lea		rsi,[marca] ;copia dir de marca en rsi
	lea		rdi,[vecMarcas + rbx]
repe cmpsb ; compara tanto bytes como lo indica rcx entre rsi,rdi
	pop		rcx;desapilo y recupero a 4 de la pila y rcx vuelve a ser 4


regListado		times	0 	db ''	;Longitud total del registro: 25
	  marca			times	10	db ' '
	  anio			times	4	db ' '
	  patente		times	7	db ' '
	  precio		times	4	db ' '