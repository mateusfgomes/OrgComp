#include <stdio.h>
#include <math.h>

int main(void){
	
	int n;//n -> numero de usuarios da base de dados
	int i;// i -> o numero de itens da base de dados
	double t;// t -> o limiar de itens da base de dados
	scanf("%d ", &n);
	scanf("%d ", &i);
	scanf("%lf", &t);
	int k,f,g,y;
	int usuario1, usuario2;
	int contadornotas[n]; //conta quantos notas ao usuario ja foram atribuidas
	int mat[n][i];//tabela de usuario x item
	int contadordezeros[n]; //conta zeros
	int contadordesconhecidos;
	int contador_DI;
	double nota[n];
	double sim[n][n];// matriz de similaridades
	double media_do_usuario[n];//vetor de media de todas as notas de cada usuario
	double pseudonota;
	double soma;
	double media;//numerador da média
	double contadorzero;//denominador da média

	//inicializando matriz de similaridade
	for (k = 0; k < n; k++){
		for (y = 0; y < i; y++){
			sim[k][y] = 0;
		}
	}
	//inicializando o vetor que conta os zeros
	for(y = 0; y < n; y++){
		contadordezeros[y] = 0;
	}

	//inicializando o vetor de medias de todos os filmes de cada usuario
	for(y = 0; y < i; y++){
		media_do_usuario[y] = 0;
	}

	//leitura matriz usuario x item	
	for (k = 0; k < n; k++){
		for (f = 0; f < i; f++){
			scanf("%d", &mat[k][f]);
		}
	} 
		
	//inicializando o vetor que conta os usuarios que ja tem notas
	for(y = 0; y < n; y++){
		contadornotas[y] = 0;
	}
	
	//similaridade entre dois usuarios
	for (usuario1 = 0; usuario1 < n; usuario1++){
		for (usuario2 = 0; usuario2 < n; usuario2++){
			if (usuario1 != usuario2){
				int	cima = 0;//numerador u.v
				double b0 = 0;//denominador 1 ||u||
				double b1 = 0;//denominador 2 ||v||
		
				for(f = 0; f < i; f++){
					cima = cima + (mat[usuario1][f] * mat[usuario2][f]);
					}
	
				for(f = 0; f < i; f++){
					b0 = b0 + (mat[usuario1][f] * mat[usuario1][f]);
				}
	
				for(f = 0; f < i; f++){
					b1 = b1 + (mat[usuario2][f] * mat[usuario2][f]);
				}	
				//cos(u,v) = (u.v)/ (||u|| . ||v||)
				sim[usuario1][usuario2] = (cima) / (sqrt(b0) * sqrt(b1));
			}	
		}
	}

	media = 0;//numerador da média
	contadorzero = 0;//denominador da média

	//percorre as notas de cada usuario e faz a media delas
	for(k = 0; k < n; k++){
			contadorzero = 0;
		for (y = 0; y < i; y++){
			//se a nota for zero, nao conta para a media
			if(mat[k][y] != 0){
				contadorzero = contadorzero + 1.0;
				media = media + mat[k][y];
			}
			//conta as notas zero encontradas
			else if (mat[k][y] == 0){
				contadordezeros[k]++;
			}
			if (y == (i-1)){
				media_do_usuario[k] = (double)(media) / (double)contadorzero;
				media = 0;
			}
		}
	}
	
	pseudonota = 0;
	soma = 0;
	contador_DI = 0;
	contadordesconhecidos = 0;

	for(g = 0; g < n; g++){
		for (f = 0; f < i; f++){
			if (mat[g][f] == 0){

				contadornotas[g] = contadornotas[g] + 1;
				for(y = 0; y < n; y++){
					if (g != y && (sim[g][y] > t) && mat[y][f] != 0){
						pseudonota = pseudonota + ((sim[g][y] * (mat[y][f] - media_do_usuario[y])));
						contador_DI++; //conta quantas vezes entrou aqui, logo, quantas vezes calculou a nota;
					}
				}
				// percorre a matriz de similaridades, soma e atribui no vetor
				soma = 0;
				for(y = 0; y < n; y++){
					//se a similaridade for acima da limiar e o outro usuario tiver avaliado o filme tb, soma
					if ((sim[g][y] > t) && mat[y][f] != 0 ){
						soma += sim[g][y];
					}
				}
				//se o contador for zero, nao fez nenhuma conta
				if (contador_DI == 0){  //
					printf("DI ");
				}
			    //conta quantos avaliaram o filme
				for (k = 0; k < n; k++){
					if(mat[k][f] == 0){
						contadordesconhecidos++;
					}
				}
				if (contadordesconhecidos == n){
					printf("DI ");
				}
				//para calcular a nota atribuida a um usuario
				if (contadordesconhecidos != n && contador_DI != 0){
					nota[g] = media_do_usuario[g] + (pseudonota/soma);
					printf("%.2lf ", nota[g]);
				}
				// /n para colocar as notas em linhas
				if (contadornotas[g] == contadordezeros[g]){
					printf("\n");
				}
				pseudonota = 0;
			}
			contadordesconhecidos = 0;
			contador_DI = 0;				
		}
	}
}



	
	
		
		

	
