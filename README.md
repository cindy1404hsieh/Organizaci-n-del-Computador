# Organizacion-del-Computador
### Enunciado del TP:
## Conversor entre IEEE 754 y Notación Científica Normalizada en Base 2 en Assembler
 1)Ingresar configuraciones hexadecimal o binarias de numeros almacenados en formato IEEE 
 754 de presicion simple e imprima su notacion cientifica normalizada en base 2
(Ej +1,110101 x 10^101)  

 2)Ingresar notacion cientifica normalizada en base 2 y visualizar su 
 configuraciones hexadecimal o binarias de dicho numero almacenado 
 en formato IEEE 754 de presicion simple
## Linea para ejecutar el programa
```
nasm -f elf64 -o conversor.o conversor.asm
```
```
ld -o conversor conversor.o
```
```
./conversor
```
