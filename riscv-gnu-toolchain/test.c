// int main(){
// 	int a;
// 	int b;
// 	int c;
// 	a = 1;
// 	b = 0;
// 	c = a+b;
// 	return 0;
// }

int main(){
	int i;
	int* leds = (int*)0x14;
	for(i=0; i<212; i++){
		*leds = i;
	}
	*leds = 0525; 
}