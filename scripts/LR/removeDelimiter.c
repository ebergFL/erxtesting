#include <stdio.h>

main(){
    char price[]="1,234,567.89";
	char output[20];
	int i, j, delimiter = 44; //Char value of comma (44)

	i = j = -1;

	do if ( price[++i] != delimiter ) output[++j] = price[i];
	while (price[i]);
	printf (
		"The price string was \"%s\"\n"
		"The output string is \"%s\"\n", 
		price, 
		output
		);
}

/*
$  gcc -o erx string2string.c&&./erx
The price string was "1,234,567.89"
The output string is "1234567.89"
*/