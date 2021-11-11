## Update

1.After adding all files to Cart in GDC, I have downloaded TCGA data from [GDC](https://portal.gdc.cancer.gov/) by clicking manifest.

 ![](images/Manifest.png?raw=true)

2. You need to download "gdc-client" form google and put it in your work directory and copy your work directory path into the ".zshrc" file.

3. Then, after reopening the terminal, please use the command ```nohup gdc-client download -m ~/path_to_your_file/manifest.txt &```

4. I will put all files in new directory called "x".

5. unzip all files in by using the command ```gunzip *htseq.counts```

6. merge all files by following the script.

7. download the other form of your data in GDC by clicking Metadata.

8. follow the script i presented.

upload any/all scripts. Within a subdirectory called scripts

upload Excel, however all filtering of files must be done in R by the end.

Please use relative paths (~/myproject), not absolute paths (/home/davidcraig/myproject). 

please take a picture of your status, and make it visible within the Gitub in line. 
 simply append ?raw=true to the image url will make the trick:
 ![](images/mypciture.png?raw=true)
 If you are doing R, this picture would show where you are in vignette
 
 ## Next Steps

 What steps are you going to do for milestone 2. may be just a repeat of previously.
 
##  Data
 
 Not due by Milestone 1, but I will address.
 Please put your data in a shared GoogleDrive folder as a tar/zip file called finalproject.tar.gz which upon untaring with tar -xvzf finalproject.tar.gz will create a folder called data that contains all your data in a way that your script can operate off of.  This section will create a link that shared dataset.
 
##  Known Issues. 

 You will have modifications and things you did that did not work.  Anything that you were not able to address yet or plan to address should be in a specific section called 'known issues'.
 If you are having any problems or need a time extension. Address this as a known issue and just modify your next steps. As long as you document this by end of day on Thursday, you will recieve credit.
