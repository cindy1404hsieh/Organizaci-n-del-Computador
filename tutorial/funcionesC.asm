Manejo de parametros
rax           rdi rsi rdx rcx r8 r9 stack...

type funcName(p1, p2, p3, p4, p5, p6, p7,..., pn)

puts

Imprime un string hasta que encuentra un 0 (cero binario). Agrega el
caracter de fin de línea a la salida
int puts(const char *str)

cadena db "Hola",0

	. . .
	mov rdi,cadena
	sub rsp,8
	call puts
	add rsp,8


printf

Convierte a string cada uno de los parámetros y los imprime con el
formato indicado por pantalla.
int printf(const char *format, arg-list)

msj db “Direccion %s %li”,0
calle db “Paseo Colon”,0
num dq 955
	. . .
	mov rdi,msj
	mov rsi,calle 
	mov rdx,[num]
	sub rsp,8
	call printf
	add rsp,8 

Función printf - Especificadores de Formato
%hhi número entero con signo base 10   8 bits 
%hi  número entero con signo base 10  16 bits
%i   número entero con signo base 10  32 bits
%li  número entero con signo base 10  64 bits


%o número entero sin signo base  8 32 bits
%x número entero sin signo base 16 32 bits

%c caracter
%s string

gets

Lee una serie de caracteres ingresados por teclado hasta que se
presiona ‘enter’ y los almacena en el campo en memoria indicado por
parámetro. Agrega un 0 binario al final.

char *gets(char *buffer)

texto resb 100
	. . .
	mov rdi,texto
	call gets

sscanf

Lee una serie de datos desde un string y, de ser posible, los guarda en
el formato indicado para cada uno. Retorna la cantidad de datos que se
convirtieron correctamente en el rax.

int sscanf(const char *buffer,const char *format, arg-list)
lee desde buffer con el formato format y lo guarda en arg-list, guarda cantidad de datos leido en rax.

numFormat db “%li”,0
. . .
string resb 100
numero resq 1
	. . .
	mov rdi,string
	mov rsi,numFormat
	mov rdx,numero
	sub		rsp,8
	call sscanf
	add		rsp,8
	cmp rax,1
	jl error

lee desde string con el formato numFormat y lo guarda en numero, guarda cantidad de datos leido en rax.


fopen
Abre el archivo especificado en fileName, en el modo especificado en
mode. Retorna un id de archivo o un código de error en rax(valor negativo).

FILE * fopen( char * fileName, char * mode )


fileName  db “Miarchivo.txt”,0
modo 	  db "r+",0
idArchivo dq 0

	. . .
	mov 	rdi,fileName
	mov 	rsi,modo
	sub		rsp,8
	call 	fopen
	add		rsp,8

	cmp rax,0
	jle errorOPEN
	mov [idArchivo],rax
;rax puede ser o negativo o un id
;si rax es un id--> copio lo que esta en rax en  [idArchivo]
;y ahora [idArchivo] funciona como
;[idArchivo] = FILE * fp

Id mode Tipo Archivo Operacion              Modo Apertura
r       texto        abre (si existe)       lectura
w       texto        trunca/crea            escritura
a       texto		 abre (si existe)/crea  agregar (append)
r+      texto		 abre (si existe)       lectura + escritura
w+      texto		 trunca/crea  			escritura + lectura
a+      texto		 abre (si existe)/crea  agregar (append) + lectura
rb      binario		 abre (si existe) 		lectura
wb      binario	 	 trunca/crea 			escritura
ab      binario      abre (si existe)/crea  agregar (append)
rb+     binario      abre (si existe) 		lectura + escritura
wb+     binario      trunca/crea 			escritura + lectura
ab+     binario      abre (si existe)/crea  agregar (append) + lectura


fgets-texto
Lee los siguientes size bytes (o hasta encontrar el fin de línea) del archivo
identificado por fp y los copia en s. Retorna la dirección de s o un código de
error.
char *fgets(char *s, int size, FILE *fp)

modo db "r",0
. . .
idArchivo resq 1
registro resb 81
	. . .
	mov rdi,registro
	mov rsi,80
	mov rdx,[idArchivo]
	call fgets

	cmp rax,0
	jle EOF


fread-binario
Lee los siguientes n(=1) bloques de tamaño size bytes del archivo identificado por fp
y los copia en p. Retorna la cantidad de bloques leidos o un código de error.

int fread (void *p, int size, int n, FILE * fp)

modo db "rb",0
. . .
idArchivo resq 1
registro times 0 resb 22
	id 	 		 resw 1
	nombre 		 resb 20
	. . .
	mov rdi,registro
	mov rsi,5
	mov rdx,1
	mov rcx,[idArchivo]
	sub		rsp,8
	call fread
	add		rsp,8

	cmp rax,0
	jle EOF

fputs-texto
Copia los bytes apuntados por s hasta encontrar el 0 binario (este último no
se copia) en el archivo identificado por fp. Retorna un valor negativo en caso
de error o fin de archivo.
char *fputs(const char *s, FILE *fp)

modo db “w+",0
linea db “9557/7503”,0
. . .
idArchivo resq 1
	. . .
	mov rdi,linea
	mov rsi,[idArchivo]
	sub		rsp,8
	call fputs
	add 	rsp,8
	. . .

fwrite-binario
Copia n bloques de size bytes en el archivo identificado por fp. Retorna la
cantidad de bloques escritos o un código de error.
int fwrite(void *p, int size, int n, FILE * fp)

modo db “wb+",0
registro times 0 db “”
	id  dw 2020
	mes db “ENE”
. . .
idArchivo resq 1
	. . .
	mov rdi,registro
	mov rsi,5
	mov rdx,1
	mov rcx,[idArchivo]
	sub		rsp,8
	call fwrite
	add		rsp,8
	. . .

fclose
Cierra el archivo identificado por fp.

void fclose(FILE *fp)

	. . .
idArchivo resq 1
	. . .
	mov rdi,[idArchivo]
	call fclose
	. . .
