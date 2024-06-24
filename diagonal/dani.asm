global  main
 
extern puts, printf, fopen, fread

section .data
	file	db	"diagonales.dat",0
	fileMode	db	"rb",0
  fileId dq 0
  errorOpenMsj db "Error al abrir el archivo"

	registro		        times	0 db ''	;Longitud total del registro: 16
	  filVerticeSup			times	4	db ' '
	  colVerticeSup			times	4	db ' '
	  filVerticeInf     times	4	db ' '
	  colVerticeInf		  times	4	db ' '

  matriz  dw	1,1,1,1,1,1,1,1,1,1 ; Matrix arbitraria
			    dw  2,2,2,2,2,1,1,1,1,1
			    dw	3,3,3,3,3,1,1,1,1,1
			    dw	4,4,4,4,4,1,1,1,1,1
			    dw	5,5,5,5,5,1,1,1,1,1
			    dw	5,5,5,5,5,1,1,1,1,1
			    dw	5,5,5,5,5,1,1,1,1,1
			    dw	5,5,5,5,5,1,1,1,1,1
			    dw	5,5,5,5,5,1,1,1,1,1
			    dw	5,5,5,5,5,1,1,1,1,1
  promedioMayorEncontrado dw 0
  msjPromedio db "El promedio encontrado fue %i",0

section .bss
	registroValido	resb 1
	datoValido		resb	1
	diagonalValida		resb	1
  distanciaDiagonal resb 1
  diferenciaEnX resb 1
  diferenciaEnY resb 1
  desplazamiento resw 1
  sumatoria resw 1

section .text
main:
  ;abro el archivo
  mov rdi,file
  mov rsi,fileMode

	sub		rsp,8
	call	fopen
	add		rsp,8

  cmp		rax,0
	jle		errorOpen
	mov   [fileId],rax

leerRegistro:
  ;leo registro
  mov rdi,registro
  mov rsi,4
  mov rdx,1
  mov rcx,[fileId]

  sub		rsp,8  
	call  fread
	add		rsp,8

  ;no se pudo leer más
	cmp   rax,0
  jle    salidaPrograma
  
  ;valido
  sub		rsp,8  
  call VALREG
	add		rsp,8

  cmp byte[registroValido],'N'
  je leerRegistro

  ; calculo promedio y actualizo si resulta ser mayor
  sub		rsp,8  
  call calcularPromedio
	add		rsp,8

  jmp leerRegistro

errorOpen:
  mov		rdi,errorOpenMsj
	sub		rsp,8
	call	puts
	add		rsp,8
  jmp   finPrograma

salidaPrograma:
  mov		rdi,msjPromedio
  mov		rsi,promedioMayorEncontrado
	sub		rsp,8
	call	printf				
	add		rsp,8

closeFile:
  mov		rdi,[fileId]
	sub		rsp,8
	call	fclose				
	add		rsp,8

finPrograma:
ret

; Subrutinas internas
VALREG:
  mov   byte[registroValido],'N'

  sub		rsp,8
	call	validarDatos
	add		rsp,8
	cmp		byte[datoValido],'N'
	je		finValidarRegistro

  sub		rsp,8
	call	validarDiagonalidad
	add		rsp,8
	cmp		byte[diagonalValida],'N'
	je		finValidarRegistro

  mov   byte[registroValido],'S'
ret

; Validación de datos (en rango válido >=1 x <= 10)
validarDatos:
  mov   byte[datoValido],'N'

  ; valido fila vertice sup
  mov ax,filVerticeSup
  cmp ax,10
  jg finValidarRegistro

  cmp ax,1
  jl finValidarRegistro

  ; valido columna vertice sup
  mov ax,colVerticeSup
  cmp ax,10
  jg finValidarRegistro

  cmp ax,1
  jl finValidarRegistro

  ; valido fila vertice inf
  mov ax,filVerticeInf
  cmp ax,10
  jg finValidarRegistro

  cmp ax,1
  jl finValidarRegistro

  ; valido columna vertice inf
  mov ax,colVerticeSup
  cmp ax,10
  jg finValidarRegistro

  cmp ax,1
  jl finValidarRegistro

  mov byte[datoValido],'S'
ret

validarDiagonalidad:
	mov		byte[diagonalValida],'N'

  ; valido que el superior efectivamente esté "arriba del inferior"
  mov ax,filVerticeSup
  cmp ax,[filVerticeInf]
  jge finValidarRegistro; si la fila del vértice inferior es mayor o igual está mal

  mov ax,colVerticeSup
  cmp ax,[colVerticeInf]
  jge finValidarRegistro; si la columna del vértice inferior es mayor o igual está mal

  ; valido que forme una diagonal. Para ello la distancia de el inferior debe ser igual en X como en Y con respecto al sup
  mov ax,filVerticeInf
  sub ax,filVerticeSup
  mov byte[diferenciaEnY],ax

  mov ax,colVerticeInf
  sub ax,colVerticeSup
  mov byte[diferenciaEnX],ax

  mov ax,diferenciaEnY
  cmp ax,diferenciaEnX
  jne finValidarRegistro ; Si las diferencias no son iguales es porque no es una diagonal

  mov distanciaDiagonal,ax ; guardo la distancia de diagonal actual para no volver a calcularla para sacar el promedio luego

	mov	byte[diagonalValida],'S'
ret

finValidarRegistro:
ret

; Calcular promedio
calcularPromedio:
  mov [sumatoria],0 ;reseteo la sumatoria a 0

  ; guardo la distancia de la diagonal en rcx para loopear con ella
  ; la idea sería recorrer todas las posiciones de la diagonal
  ; e ir sumando. Partimos de la distancia (el mas alejado)
  ; y mediante loop va restando hasta llegar al punto sup.
;calcularPromedio: creo que va aca.
  mov rcx,distanciaDiagonal 

  ; calculo el desplazamiento
  ;  [(fila-1)*longFila]  + [(columna-1)*longElemento]
  ;  longFila = longElemento * cantidad columnas
  mov  bx,filVerticeSup
  add  bx,distanciaDiagonal
  sub  bx,1
	imul bx,20		; desplanzamiento en la fila. cant filas (10) * tam elemento (2 bytes = word)
  mov	 [desplazamiento],bx

  mov  bx,colVerticeSup
  add  bx,distanciaDiagonal
  sub  bx,1
	imul bx,2		; desplanzamiento en la columna. tam elemento = 2 bytes (word)

  add	 [desplazamiento],bx

  mov rcx,[desplazamiento]
  mov rax,[matriz + rcx] ; guardo en rax el valor hubicado en la posicion acorde al elemento (desplazamiento)

  add [sumatoria],rax ; sumo a la sumatoria el elemento contenido

  loop calcularPromedio

  mov rax,sumatoria ; guardo la sumatoria en ax para dividir
  mov rcx,distanciaDiagonal
  add rcx,1 ; sumo 1 a la distancia para incluir los extremos tambien
  idiv distanciaDiagonal

  ; comparo si el promedio resulta mayor al actual, de ser el caso hago jump para ir a actualizarlo
  cmp rax,promedioMayorEncontrado 
  jg actualizarPromedio
ret

actualizarPromedio:
  mov [promedioMayorEncontrado],ax
ret