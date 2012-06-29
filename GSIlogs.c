/*
GSI Log Converter
Eric H. Berg
Reads in a GSI trim log file and outputs to an Apache Combined Log Format (ACLF) with VHOST
Combined Log Format > LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"" combined
Example output > 127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)"
*/

#include <stdio.h>
#include <string.h>
#define fopenc(POINTER, FILE, MODE) if((POINTER = fopen(FILE, MODE)) == NULL){printf("Can not open file: FILE");exit(0);}
#define MAX_STRING 10000

char *GSI2ACLF1(char *line);

int main(void) {
	int i, j;
	unsigned int linecount = 0;
	unsigned int maxlength = 0;
	FILE *infile, *outfile;
	char getline[MAX_STRING];
	char tempstring[MAX_STRING] = "";
	char *infilename =
		"c:\\temp\\gsi\\logs\\in.log";
	char *outfilename =
		"c:\\temp\\gsi\\logs\\out.log";

	// Open the text file with read access
	fopenc(infile, infilename, "rt");
	fopenc(outfile, outfilename, "wt+");
	// Read until end of file
	while (fgets(getline, MAX_STRING, infile) != NULL) {
		maxlength = (strlen(getline) < maxlength) ? maxlength : strlen(getline);//Find the longest line read
		if ((++linecount % 100000) == 0) printf("Processing line: %d\r", linecount);//This could slow down the conversion

		//Copy the line read from file to a tempt string, add date and fill empty fields with a hyphen "-"
		strcpy(tempstring, "[29/Nov/2010:");//Every day is November 29, 2010 :)
		i=0;
		j=strlen(tempstring);
		while ( (tempstring[j] = getline[i]) != '\0' ) {
			if (getline[i] == '"' && getline[i+1] == '"') tempstring[++j] = '-';
			i++;
			j++;
		}

		fputs(GSI2ACLF1(tempstring), outfile);//Convert the line read in and write it to the outfile
		// Check for file I/O errors
		if (ferror(infile)) printf("Error reading file %s\n", infilename);
	}

	// Display file stats
	printf("Total number of lines read = %d\nMax line length = %d\n", linecount, maxlength);

	// Close the file stream
	if (fclose(infile))		printf("Error closing file %s\n", infilename);
	if (fclose(outfile))	printf("Error closing file %s\n", outfilename);
	return 0;
}

char *GSI2ACLF1(char *line) {
	int fieldcount = 0;
	static char lineout[MAX_STRING] = "";
	char temp[MAX_STRING] = "";
	char vhost[MAX_STRING] = "";
	char status[MAX_STRING] = "";
	char agent[MAX_STRING] = "";
	char *t1;

	for ( t1 = strtok(line,"\"");
			t1 != NULL;
			t1 = strtok(NULL, "\"") ) {
		switch (fieldcount++) {
			case 0 :
				sprintf(lineout, "%s -0500]", t1);//Time stamp
				break ;
			case 1 :
				sprintf(vhost, "%s", t1);
				break ;
			case 2 :
				sprintf(temp, "%s - - %s", t1, lineout);//IP
				strcpy(lineout, temp);
				break ;
			case 3 :
				sprintf(status, "%s", t1);//Status code
				break ;
			case 4 :
				switch((t1 > "G") + (t1 > "H") + (t1 > "P")) {	//
				case 0 :
					sprintf(temp, "%s \"%s " , lineout, "GET");
					strcpy(lineout, temp);
					break;
				case 1 :
					sprintf(temp, "%s \"%s " , lineout, "HEAD");
					strcpy(lineout, temp);
					break;
				case 2 :
					sprintf(temp, "%s \"%s " , lineout, "PUT");
					strcpy(lineout, temp);
					break;
				default :
					break ;
				}
				break ;
			case 5 :
				sprintf(temp, "%s%s HTTP/1.0\" %s" , lineout, t1, status);//URL
				strcpy(lineout, temp);
				break ;
			case 7 :
				sprintf(temp, "%s %s" , lineout, t1);//Size
				strcpy(lineout, temp);
				break ;
			case 10 :
				sprintf(agent, "%s", t1);//Agent
				break ;
			case 11 :
				sprintf(temp, "%s \"%s\" \"%s\" %s\n" , lineout, t1, agent, vhost);//Referer
				strcpy(lineout, temp);
				break ;
			default :
				break ;
		}
	}
	return lineout;
}
