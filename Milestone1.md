## Update

1.After adding all files to Cart in GDC, I have downloaded TCGA data from [GDC](https://portal.gdc.cancer.gov/) by clicking manifest.

 ![](Images/Manifest.png?raw=true)

2. You need to download "gdc-client" form google and put it in your work directory and copy your work directory path into the ".zshrc" file.

3. Then, after reopening the terminal, please use the command:

   ```nohup gdc-client download -m ~/path_to_your_file/manifest.txt &```

4. I will put all files in new directory.

5. unzip all files in by using the command:

   ```gunzip *htseq.counts.gz```

6. use part of the samples for testing.

7. follow the script i presented.
 
 ## Next Steps

I will run throught the SOP I presented above and try to ruduce errors within my contexts. Maybe run more data to test my script.
 
##  Data
 
I have uploaded" Sample_young.csv" and "result.txt".

 Please put your data in a shared GoogleDrive folder as a tar/zip file called finalproject.tar.gz which upon untaring with tar -xvzf finalproject.tar.gz will create a folder called data that contains all your data in a way that your script can operate off of.  This section will create a link that shared dataset.
 
##  Known Issues

1.I have met issue with the content in DESeq2 guildlines. However, after discussing with Dr. Craig, problems solved but still need to retest my whole testing scripts.

2.It is hard to put all files into the scripts that I run, but I will put more data and samples into my scripts eventually.
