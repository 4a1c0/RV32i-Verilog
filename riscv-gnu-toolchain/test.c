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
	int i = 0;
	int* leds = (int*)0x14;
	for(i=0; i<32; i++){
		*leds = i;
	}
	*leds = 0777; 
}