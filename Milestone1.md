## Update 

### Data filtering

First, go to [GDC](https://portal.gdc.cancer.gov/) and click on "**Repository**".

On the left side "**Files**" filters:

Data Category - "**transcriptome profiling**".

Data Type - "**Gene Expression Quantification**".

Experimental Strategy - "**RNA-Seq**".

Workflow Type - "**HTSeq - Counts**".

   ```gunzip *htseq.counts.gz```

Access - "**open**".

![](Images/Files.png?raw=true)

On the left side "**Cases**" filters:

First, click "**Add a Case/Biospecimen Filter**"

Then, type "**Gleason Grade**" and select "**primary_gleason_grade**".

Diagnoses Primary Gleason Grade - "**pattern 3**" and "**pattern 4**".

Primary Site - "**prostate gland**".

Program - "**TCGA**".

Disease Type - "**adenomas and adenocarcinomas**".

Gender - "**male**".

Age at Diagnosis - From "**55**" to "**64**".

Vital Status - "**alive**".

Race - "**white**" and "**black or african american**".

![](Images/Cases.png?raw=true)

In this group, I got 225 files but only 203 cases. 

Later, open a new webpage of [GDC](https://portal.gdc.cancer.gov/). I will select another group with all the same filters except Age at Diagnosis (From "**65**" to "**75**"). I got 146 files but only 128 cases.

### Data downloading

After selecting all files to Cart in GDC, I have downloaded TCGA data by clicking **Manifest**.

![](Images/Manifest.png?raw=true)

You have to download "gdc-client" form [GDC Data Transfer Tool](https://gdc.cancer.gov/access-data/gdc-data-transfer-tool) by choosing **gdc-client_v1.6.1_OSX_x64.zip** and put it in your work directory and copy your work directory path into the ".zshrc" file like this:

```vi ~/.zshrc```

```export PATH="/path to your gdc-client/:${PATH}"```

Then, after reopening the terminal, please use the command:

```nohup gdc-client download -m ~/path_to_your_file/your_manifest.txt     &```

I will put all files in new directory.

unzip all files in by using the command:

```gunzip *htseq.counts```

The first group which age between 55-64, I will put them in a folder called "young" and change all their names with the prefix "younggroup".

The second group which age between 65-75, I will put them in a folder called "old" and change all their names with the prefix "oldgroup".

![](Images/all_files.png?raw=true)

Then, merge all files into a new folder called "all".

## Next Steps

I will run throught the SOP I presented above and try to ruduce errors within my contexts. Maybe run more data to test my script. Then, I will start to create plots from the vignette.

##  Data

I have uploaded" Sample_young.csv", "result.txt", and all my "htseq.counts" files.

##  Known Issues

I have met issue with the content in DESeq2 guildlines. However, after discussing with Dr. Craig, problems solved but still need to retest my whole testing scripts.

It is hard to put all files into the scripts that I run, but I will put more data and samples into my scripts eventually.
