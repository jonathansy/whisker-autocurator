Documentation on Installation and Use of the Whisker Autocurator
======
*Written 2018-06-11 by J. Sy*

[![Hires Lab](https://github.com/jonathansy/whisker-autocurator/blob/master/Resources/Images/HiresLab-logoM.png)](http://68.181.113.239:8080//hireslabwiki/index.php?title=Main_Page)

Table of Contents 
------
[Installation](https://github.com/jonathansy/whisker-autocurator/blob/master/Autocurator_Beta/README.md#installation)

[Cloud ML Setup](https://github.com/jonathansy/whisker-autocurator/blob/master/Autocurator_Beta/README.md#cloud-ml-setup)

[Local Drive Setup](https://github.com/jonathansy/whisker-autocurator/blob/master/Autocurator_Beta/README.md#local-drive-setup)

[Operation and Use](https://github.com/jonathansy/whisker-autocurator/blob/master/Autocurator_Beta/README.md#operation-and-use)

[Troubleshooting](https://github.com/jonathansy/whisker-autocurator/blob/master/Autocurator_Beta/README.md#troubleshooting)

Installation 
------
In addition to all the scripts in this repository, you will also require a working Google Cloud Services account. Curation can be done using either a VM or CloudML, but these scripts have been optimized for Cloud ML. Additionally, you will require a functional trial array and an empty contact array for your data. These can be created using software found in the Hires Lab repository [HLab_MatlabTools](https://github.com/hireslab/HLab_MatlabTools). The scripts in [HLab_Whiskers](https://github.com/hireslab/HLab_Whiskers) will also need to be added to the MATLAB path to instantiate the trial arrays. 

Clone or download the scripts in this directory as well as the HLab dependencies and add both to the path. Currently the trial contact browser in HLab_Matlabtools is backwards compatible to MATLAB 2013b. The autocurator scripts in here may be compatible with older versions but have not been tested as such. 

Cloud ML Setup
------
If you intend to use the cloud curation scripts in this package, you will first need to setup a consistent directory structure within a Google Cloud Bucket. Buckets are a form of cloud data storage. Information about creating and using them can be found [here](https://cloud.google.com/storage/docs/creating-buckets). After creating a cloud storage bucket for your training jobs, you should create the following directories:
/Jobs for storing output logs from curation
/Data for importing uncurated image data 
/Curated_Data for placing curated labels for export 
/Model_Saves for placing the model(s) you wish to use for curation.

Cloud storage buckets begin with the prefix gs://, for example gs://my_bucket/Data. Make sure all relevant cloud paths are set within [autocurator_master_function.m](https://github.com/jonathansy/whisker-autocurator/blob/master/Autocurator_Beta/autocurator_master_function.m). Cloud storage buckets do not have the same functionality as local drives and thus will not display their properties or index files. They also require the File_IO package to index on Python (included with Tensorflow). 

Submitting training jobs to CloudML do not require manually setting up virtual machines on Google's cloud console. You will have to specify certain settings for the curation environment when you submit a job to the cloud. These are handled via  the 'gcloud ml-engine jobs submit' command as well as a .yaml file included in the local directory. Important variables to specify are the type of GPU (if any) to use, the runtime environment, and the [region](https://cloud.google.com/compute/docs/regions-zones/) (note that only certain regions support GPU use).    

Local Drive Setup 
------

Operation and Use
------

Troubleshooting
------
