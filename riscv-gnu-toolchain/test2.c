
int main(){
	int i = 0;
	int* leds = (int*)0x14;
	*leds = 0777; 
	*leds = 0707; 
	*leds = 0001; 
	i = *leds;
	i = i<<2;
	*leds = i;
	*leds = 0000; 
}