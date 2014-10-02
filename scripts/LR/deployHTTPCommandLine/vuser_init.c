vuser_init()
{
	system("copy commandLine.txt commandLine.bat >> c:\\commandLine.log");
	system("commandLine.bat >> c:\\commandLine.log");

	//Output the data to a file
	int fp;
	long i;

	fp = fopen("c://lr_tools//myfile.bin","wb");//Truncate to zero length or create file for writing

	web_set_max_html_param_len("100000");//Set the parameter size large enough to save the data

	web_reg_save_param("FILED","LB=","RB=","Search=Body",LAST);//Use web_reg_save_param with the correct boundary to capture the data returned by the server

	web_url("");

	i = web_get_int_property( HTTP_INFO_DOWNLOAD_SIZE );//Get the download size

	fwrite(lr_eval_string("{FILED}"),i,1,fp);//Write the data saved to an output file

	fclose(fp);

	return 0;
}
