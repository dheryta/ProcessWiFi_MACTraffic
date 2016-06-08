# CausalAnalysis
This code should be placed in home folder<br />
Folder structure required $HOME/Scripts/CausalAnalysis/<br />
This code process packet captures (PCAPs) to analyze the cause of active scanning in WiFi networks.<br />
It converts PCAPs to CSVs.<br />
<br />
Main File to execute: CodeFlow.sh<br />
#./CodeFlow.sh<br />
<br />
It will ask for following details:<br />
	1. Name of dataset to be processed<br />
	2. EDCA Enabled<br />
	3. Header - Radiotap or Prism<br />
	4. Convert PCAP to CSV required <br />
		[PCAPs should be placed at $HOME/Datasets_PCAPs/<Name of dataset>/Date/<PCAPs>]<br />
		[CSVs should be placed at $HOME/Datasets_CSVs/<Name of dataset>/Day#_Merged.csv]<br />
	5. What do you want to process?<br />
		a. APs and Clients<br />
		b. Filter Traffic<br />
		c. Frame Details<br />
		d. Airtime Utilization<br />
		e. Useless Probe Traffic<br />
		f. Quantify Causes<br />

Output Path of processed result: $HOME/DataAnalysis/<Name of dataset>/Day#, One folder for each of the above will be created:<br />
		a. APs-Clients  <br />
		b. FindNumberofFrames  <br />
		c. FindAllTrafficDetails  <br />
		d. ATU  <br />
		e. UselessProbeTraffic<br />
		f. CausalAnalysis-Datasets  <br />



