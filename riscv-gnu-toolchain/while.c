
int main(){
	int i = 0;
	int* leds = (int*)0x14;
	while(1){
		*leds = i;
		i++;
	}
}