#define BUFFER_SIZE 10240 // 10 KB
 
lr_popen()
{
    long fp; // file/stream pointer
    int count; // number of characters that have been read from the stream.
    char buffer[BUFFER_SIZE]; // allocate memory for the output of the command.
 
    // "VER" outputs the version of Windows that is running.
    if (!(fp = popen("VER", "r"))) {
        lr_error_message("Error opening stream.");
        return -1;
    }
 
    count = fread(buffer, sizeof(char), BUFFER_SIZE, fp); // read up to 10KB
    if (feof(fp) == 0) {
        lr_error_message("Did not reach the end of the input stream when reading. Try increasing BUFFER_SIZE.");
        return -1;
    }
    if (ferror(fp)) {
        lr_error_message ("I/O error during read."); 
        return -1;
    } 
    buffer[count] = NULL;
 
    lr_output_message("The Windows version is: %s", buffer);
    pclose(fp);
    return 0;
}
