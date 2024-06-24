#define MAX_COL 5
#define MAX_FILA 5
//0| 4 6 7 2 3
//1| 1 3 2 4 5
//2| 7 2 5 3 1
//3| 1 3 1 4 6
//4| 9 2 1 4 2 
//col = 1
//fil = 1
int main()
{
	int matriz[MAX_FILA][MAX_COL];
	int fila;
	int col;
	int sumatoria = 0;

	printf("ingrese una fila(1 a 5):\n");
	scanf(" %i",fila);
	while((fila>5 || fila<0) ){
		printf("ingrese una fila correcta(1 a 5):\n");
		scanf(" %i",fila);
	}
	printf("ingrese una columna(1 a 5):\n");
	scanf(" %i",col);
	while((col>5 || col<0) ){
		printf("ingrese una columna correcta(1 a 5):\n");
		scanf(" %i",col);
	}
	for(;col < MAX_COL;col++){
		sumatoria+= matriz[fila][col];
	}
	printf("la sumatoria es: %i\n",sumatoria);
	return 0;
}