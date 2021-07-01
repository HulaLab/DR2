# DR2
This is the github repo for DR2 and includes sub folders for each aim.

## This is a subsection bolding

### Sub sub section etc

https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet#links)

### Testing to see if aswiderskiTest can change the readme

### Jeff testing access

Blue text = steps that happen on the VA Network
Black text = steps that happen on a non-VA computer 

•	Locate/create Aim 3 data folder on the DRII Drive
o	On the DRII Network Drive, find the participant’s Aim 3 data folder in \Dose Response II\Data Files\00_Aim 3.
o	If they don’t have a folder yet, make a copy of 00_Aim3_PatientTemplate and rename it for the participant (replace “00” with their study ID and delete “_PatientTemplate”).
o	Rename the Excel files ##_ScoreSheet, ##_StimOrder_01_PreTx, and ##_TimingData with the participant’s ID in place of ##.
•	Copy the participant’s picture stimuli to the Aim 3 folder
o	When the pictures have been finalized, locate them on the DRII drive in the following location: \DR II Participants\Participant Data\3086_##\3086_## Materials\3086_## Images (where ## is the participant’s ID #).
	Copy the images and paste them in the participant’s Aim 3 Objects folder, located here: \Data Files\Aim 3\##_Aim3\B_PicNaming_Files\Objects.
•	Get the list of treatment/generalization items
o	Locate the Excel file 3086_##_TargetSelection in the participant’s folder located here: \DR II Participants\Participant Data\3086_##\.
o	In the sheet called “Final,” copy the item names (“target”) and treatment status (“tx”; 1 = trained, 0 = untrained); paste them into columns A and B (“Item” and “Condition”) of the “Stimulus List” sheet in the the participant’s ##_StimOrder_01_PreTx1 file. 
o	**Be sure to delete any empty rows that are present after copying/pasting the items**
•	Set the stimulus order for picture naming scripts at pre-treatment scan 1. 
•	In the “Stimulus List” sheet of ##_StimOrder_01_PreTx1, sort the data based on Column B (“Condition”) in descending order so that trained items (Condition = 1) are listed first, followed by untrained items (Condition = 0).
•	Copy the trained item names from the “Item” column and paste them into column A on the next sheet in the file (i.e., “Trained”).
•	In the “Trained” sheet, drag/copy cell D1 through cell D30 to generate new random numbers in each cell, then sort by Column D (can be either ascending or descending). If done correctly, the Trained items should now be in random order.
•	Repeat steps 2 and 3 for the untrained items (Condition = 0).
•	 On the sheet “Scrambled_Tr,” drag/copy cell B1 through B30 to generate new random numbers, then sort based on Column B to randomize the order of the items listed in Column A. 
•	Repeat step 5 on the sheet “Scrambled_Untr.”
•	On the sheet “Scr_15each,” drag/copy cell B1 through B30 to generate new random numbers, then sort the sheet based on Column B to randomize the order of items in Column A. 
•	Once the steps above are complete, Column D of the last sheet in the file (“MasterSequence”) contains the file names for the stimulus images in the order in which they will be entered into the Eprime script for all three runs of the picture naming task for the first pre-treatment scan. Save and close the file ##_StimOrder_01_PreTx1.
•	Set the stimulus order for all remaining timepoints.
•	In the Windows browser, make three copies of ##_StimOrder_01_PreTx1 and rename them as follows:
	##_StimOrder_02_PreTx2
	##_StimOrder_03_PostTx
	##_StimOrder_04_FollowUp
•	In each of the new StimOrder files:
	On the “Trained” sheet, re-generate the random numbers (i.e., drag down from cell D1 to D30) and sort by Column D.
	On the “Untrained” sheet, drag down from cell D1 to D30 and sort by Column D. 
	On “Scrambled_Tr”, “Scrambled_Untr”, and “Scr_15each”, drag down from B1 to B30 and sort by Column B. 
	Save the file.
•	Transfer necessary files to the MRI laptop. 
•	**Note that several of the following steps must be performed on a computer running Matlab with the Image Processing Toolbox and Eprime (as of 4/16/2021, only the primary MRI laptop, Silkie, does so).**
•	Using an encrypted flashdrive or zipping the necessary files and sending them over email, transfer the following files from the VA Network to the participant’s MRI folder to the laptop (see below re: participants’ MRI folders on the laptop):
	##_StimOrder_01_PreTx1
	##_StimOrder_02_PreTx2
	##_StimOrder_03_PostTx
	##_StimOrder_04_FollowUp
	A zipped copy of the participant’s Objects folder that includes all their stimulus images. 
•	Set up the participant’s MRI folder on the laptop. 
o	On the desktop, locate the folder \DRII\MRI. 
o	Make a copy of the template folder “00_Aim3_blanktemplate” and rename with the participant’s ID, as in “##_Aim3.”
o	Save the StimOrder files and Objects folder from the VA network to the participant’s new Aim 3 folder on the laptop, under PicNaming (i.e., /DRII/MRI/##_Aim3/PicNaming).
o	Unzip the Objects folder and delete the zipped copy.
•	Blur and scramble picture stimuli for use in the picture naming task 
o	In the participant’s Objects folder, find the script file hb_imageBlur.m and open it in Matlab.
o	Edit line 1 of the script to indicate the location of the jpg image files you want to convert (i.e., the participant’s Objects folder).
	the directory name should conclude with a reference to the type of files you want to edit (in this case \*.jpg).
	The entire entry (directory\*.jpg) should be enclosed in apostrophes on each side, as in: ‘C:\Users\Research\Desktop\DRII\MRI\##_Aim3\PicNaming \Objects\*.jpg'
o	Run the script – this will copy every jpg in the directory, blur it, and save a new copy ending with _blur.jpg.
o	Open the script file scrambled_blurred.m (also in the Objects folder); edit the file as follows:
	In line 1, update the directory name, as in step 26a, above. In this case, ensure that the directory name concludes \*blur.jpg). 
	Run the script – this will copy all the jpgs ending in _blur.jpg, scramble them, and save a new copy ending with _blur_scr.jpg. Those files will be used as scrambled stimuli in the picture naming Eprime script.
•	Edit the participant’s Eprime scripts. 
•	From the participant’s PicNaming folder on the laptop, open the file ##_StimOrder_01_PreTx1 and go to the last sheet (“Master Sequence”).
•	In the same folder, locate the E-Studio template file called ##_01_PreTx1_Run1 and rename it by replacing ## with the participant’s ID. 
•	Plug the Eprime key into the laptop and open the E-Studio file. 
•	In E-Studio, navigate to and open the E-Object called “TaskTrialList”.
•	Copy the first 30 items from the Item column (Column D) in the “Master Sequence” Excel sheet (i.e., all of those with a value of 1 in the Run column) and paste them (in the same order) into the Image column of the E-Object “TaskTrialList”.
•	Save and close the E-Studio file.
•	In the participant’s folder, find the E-Studio file for PreTx1_Run2 (i.e., ##_02_PreTx1_Run2) and rename it with the participant’s ID. 
•	Open the Run2 file and repeat steps 4-6, being sure to populate the Image column of “TaskTrialList” with the items assigned to Run 2 in the “Master Sequence” sheet of ##_StimOrder_01_PreTx1.
•	Save and close the E-Studio file.
•	Repeat steps 7-9 for the E-Studio file for PreTx1_Run3 (i.e., ##_03_PreTx1_Run3), using the third set of items in the “Master Sequence” sheet.
•	To make scripts for the remaining time points:
	Rename all of the remaining E-Studio files with the participant’s ID.
	Edit the E-Studio files one at a time by copy/pasting the item names from the corresponding “Master Sequence” sheet for each time point/run. 
•	Note that each of the four Excel StimOrder files corresponds to three E-Studio script files, as follows:
1.	##_StimOrder_01_PreTx1  ##_01_PreTx1_Run1, ##_02_PreTx1_Run2, ##_03_PreTx1_Run3.
2.	##_StimOrder_02_PreTx2  ##_04_PreTx2_Run1, ##_05_PreTx2_Run2, ##_06_PreTx2_Run3.
3.	##_StimOrder_03_PostTx  ##_07_PostTx_Run1, ##_08_PostTx_Run2, ##_09_PostTx_Run3.
4.	##_StimOrder_04_FollowUp  ##_10_FollowUp_Run1, ##_11_FollowUp_Run2, ##_12_FollowUp_Run3.
•	Modify the scoresheet for online data collection.
•	**Note: before completing this step, the stimulus presentation order must have already been established for the relevant timepoint**
1.	Locate the file ##_ScoreSheet in the participant’s folder on the laptop (/DRII/MRI/##_Aim3/PicNaming) and rename it by replacing the ## with the participant’s ID.
2.	Open the Excel file ##_StimOrder_01_PreTx1 (or the StimOrder file for the relevant time point) and locate the “Master Sequence” sheet.
3.	In ##_ScoreSheet, locate the Master sheet for the timepoint of interest (i.e., “PreTx1_Master”, “PreTx2_Master”, “PostTx_Master”, or “FU_Master”).
4.	Copy the contents of Column D (including the column header, “Item”) in the “Master Sequence” sheet of the StimOrder file and paste it as values into column A of the Master sheet in ##_ScoreSheet (to paste as values, right click in cell A1 and choose the second icon in the “Paste Options” submenu).
•	If steps 1-4 were performed correctly, the Run1, Run2, and Run3 score sheets for the given timepoint (each of which has a separate tab in ##_ScoreSheet) will have autofilled with the correct items in the correct presentation order. (Note: The “Target” column of the individual Run scoresheets reflects the target response that should be produced by the participant (i.e., either the name of the picture or, for scrambled trials, the word “skip”). 
•	
