/*
 tshark -E separator=, -T fields -e frame.time_epoch -e wlan.sa -e wlan.da -e wlan.ra -e wlan.ta -e wlan.fc.type_subtype -e prism.did.channel -e wlan.duration -r WR6.pcap > PcapCSV.csv
2009
00:23:15:1b:08:3c
64:70:02:27:ae:b2
64:70:02:29:a3:76
64:70:02:29:c9:bc
bc:77:32:26:b5:10
d8:a2:5e:96:71:9d
Sensor Nodes
00:04:a3:00:00:07
00:04:a3:00:00:08
00:04:a3:00:00:09
00:04:a3:00:00:10
00:04:a3:00:00:11
00:04:a3:00:00:12
Madhur
a0:88:b4:e4:0e:28
Dheryta
44:6d:57:31:40:6f
*/
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#define Max_Frames 700000
#define SIFS 0.000011
#define Max_Channels 13

//char *Enterprise_Client = "44:6d:57:31:40:6f";
char *Enterprise_Client = "00:22:fa:c8:47:d4";
/*char *Non_Enterprise_Client1 = "00:23:15:1b:08:3c";
char *Non_Enterprise_Client2 = "64:70:02:27:ae:b2";
char *Non_Enterprise_Client3 = "64:70:02:29:a3:76";
char *Non_Enterprise_Client4 = "64:70:02:29:c9:bc";
char *Non_Enterprise_Client5 = "bc:77:32:26:b5:10";
char *Non_Enterprise_Client6 = "d8:a2:5e:96:71:9d";
*/
char *Non_Enterprise_Client1 = "00:04:a3:00:00:07";
char *Non_Enterprise_Client2 = "00:04:a3:00:00:08";
char *Non_Enterprise_Client3 = "00:04:a3:00:00:09";
char *Non_Enterprise_Client4 = "00:04:a3:00:00:10";
char *Non_Enterprise_Client5 = "00:04:a3:00:00:11";
char *Non_Enterprise_Client6 = "00:04:a3:00:00:12";
char *Non_Enterprise_AP = "4c:60:de:fc:36:00";
char *Enterprise_AP = "c4:0a:cb:5c:07:00";

struct PCAP_Data
{
double frame_time_epoch;
char wlan_fc_type_subtype[5];
int prism_did_channel;
char wlan_sa[18];
char wlan_da[18];
char wlan_bssid[18];
char wlan_ta[18];
char wlan_ra[18];
double wlan_duration;
int prism_did_rate;
int wlan_fc_retry;
int wlan_qos_priority;
}PCAP_DATA_VAL[Max_Frames];


int framesCount=0;

void LoadPCAPData(char*);
void CountFragmentOpportunity();
double calculateMean(double IFAT[], int count);

void main( int argc, char *argv[] )
{
	if ( argc != 4 )
    	{        	
        	printf( "usage: %s filename slot(seconds) AC\n", argv[0] );
    	}
	else
	{
		LoadPCAPData(argv[1]);
		CountFragmentOpportunity(atoi(argv[2]), atoi(argv[3]));
	}

}

//Load Pcap into Structure Array
void LoadPCAPData(char *pcap)
{
int frame=-1;
FILE *file = fopen(pcap, "r" );
		if (file == NULL)
		{
			printf("\n Unable to read file");
			return;
		}
		char buffer[4095];
		char *token;
		char * end;
		double temp;
		while(fgets(buffer, 4095, file) != NULL)
    		{
		    frame=frame+1;
		    token = strtok(buffer, ",");
		    if (token != NULL)
		    {
		    temp = strtod (token, & end);
			if (end == token)
			PCAP_DATA_VAL[frame].frame_time_epoch = -1;
			else
   		        PCAP_DATA_VAL[frame].frame_time_epoch =  temp;
                    }
   
		    token = strtok(NULL, ",");
		    if (token != NULL && !(strcmp(token, "EMPTY") == 0 ))
   		    strcpy(PCAP_DATA_VAL[frame].wlan_sa, token);

		    token = strtok(NULL, ",");
		    if (token != NULL && !(strcmp(token, "EMPTY") == 0 ))
   		    strcpy(PCAP_DATA_VAL[frame].wlan_da, token);
		    
		    token = strtok(NULL, ",");
		    if (token != NULL && !(strcmp(token, "EMPTY") == 0 ))
   		    strcpy(PCAP_DATA_VAL[frame].wlan_ra, token);			

		    token = strtok(NULL, ",");
		    if (token != NULL && !(strcmp(token, "EMPTY") == 0 ))
   		    strcpy(PCAP_DATA_VAL[frame].wlan_ta, token);

		    token = strtok(NULL, ",");
		    if (token != NULL && !(strcmp(token, "EMPTY") == 0 ))
   		    strcpy(PCAP_DATA_VAL[frame].wlan_fc_type_subtype, token);
		    
                    token = strtok(NULL, ",");
		    if (token != NULL && !(strcmp(token, "EMPTY") == 0 ))
   		    PCAP_DATA_VAL[frame].wlan_fc_retry =  atoi(token);
		    
		    token = strtok(NULL, ",");
		    if (token != NULL && !(strcmp(token, "EMPTY") == 0 ))
   		    PCAP_DATA_VAL[frame].wlan_qos_priority = atof(token);
		}
		framesCount=frame;
		fclose(file);

}
void CountFragmentOpportunity(long slotTime, int AC)
{
int eFrame;	
long nextFrame;
char *success;
int rtsctsFrames=0;
int dataFrames=0;
int ackFrames=0;
char address[18];

double currentTS, nextTS, finalTS;
long nextSlot;
double slot;
long simulationTime = 1800;

dataFrames=0;
rtsctsFrames=0;
ackFrames=0;
eFrame=0;
slot=(float)slotTime;

nextSlot = 1;
currentTS = PCAP_DATA_VAL[eFrame].frame_time_epoch;
nextTS = PCAP_DATA_VAL[eFrame+1].frame_time_epoch;
finalTS = currentTS + slot;


int dataSent = 0;
int totalFrames = 0;
int dispSlot = 0;
int totalFresh = 0;
int dataFresh = 0;
	while( (eFrame<framesCount-1) && (dispSlot < 300))
	{
		
		 if ((nextTS - currentTS) <= slot)
		 {
			//Calculate for this slot
			//dataSent = dataSent + checkIfEnterpriseData(PCAP_DATA_VAL[eFrame]);	//Data Frame
			totalFrames++;			
			dataFresh = dataFresh + checkIfEnterpriseDataSuccess(PCAP_DATA_VAL[eFrame],AC); //Fresh Data Frame
		 }else{
			//Calculate %
			dispSlot = (slot + nextSlot*slot)/slot;
			//long unAckd = dataSent - dataAckd;
			if (totalFrames>0){
			double percentage = 100 * ((float)dataFresh/(float)totalFrames);
			totalFresh++;
			printf("%d,%f\n",dispSlot, percentage); //Some Fresh Frames
			}
			else
			printf("%d,%d\n",dispSlot, 0); //No Frame at all

			nextSlot = nextSlot + 1; 
			totalFrames = 0;
			dataFresh = 0;
			currentTS = PCAP_DATA_VAL[eFrame].frame_time_epoch;
		 }
	eFrame++;	
	nextTS = PCAP_DATA_VAL[eFrame].frame_time_epoch;
	}
double percentage = 100 * ((float)totalFresh/(float)300);
//printf("%f",percentage);
}


int checkIfEnterpriseDataSuccess( struct PCAP_Data currentframe, int AC)
{
int retVal = 0;
	//if(strcmp(currentframe.wlan_sa,Enterprise_Client) == 0 && strcmp(currentframe.wlan_fc_type_subtype,"0x28") == 0 &&
//strcmp(nextframe.wlan_ra,Enterprise_Client) == 0 && strcmp(nextframe.wlan_fc_type_subtype,"0x1d") == 0 )
	if(strcmp(currentframe.wlan_fc_type_subtype,"0x28") == 0 &&
	currentframe.wlan_fc_retry == 0 && currentframe.wlan_qos_priority == AC)
	retVal = 1;
return retVal;
}

int checkIfEnterpriseData( struct PCAP_Data currentframe)
{
int retVal = 0;
	if(strcmp(currentframe.wlan_fc_type_subtype,"0x28") == 0)
	retVal = 1;
return retVal;
}


