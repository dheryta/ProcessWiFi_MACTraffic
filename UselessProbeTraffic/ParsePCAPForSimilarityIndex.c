/*
 tshark -E separator=, -T fields -e frame.time_epoch -e wlan.sa -e wlan.da -e wlan.ra -e wlan.ta -e wlan.fc.type_subtype -e prism.did.channel -e wlan.duration -r WR6.pcap > PcapCSV.csv
*/
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#define Max_Frames 700000
#define SIFS 0.000011
#define Max_Channels 13
#define Max_Probe_Response 10

//char *Enterprise_Client = "44:6d:57:31:40:6f";
char *Enterprise_Client = "00:22:fa:c8:47:d4";

struct Probe_Response
{
char ssid[255];
char bssid[18];
int channel;
int station_count;
}prev_probe_responses[Max_Probe_Response], curr_probe_response[Max_Probe_Response];

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
int type;
struct Probe_Response pres;
}PCAP_DATA_VAL[Max_Frames];


int framesCount=0;

void LoadPCAPData(char*);
void FindUsefulVsUselessPRes(char *SA, char *SSID);


void main( int argc, char *argv[] )
{
	if ( argc != 4 )
    	{        	
        	printf( "usage: %s filename SA SSID\n", argv[0] );
    	}
	else
	{
		LoadPCAPData(argv[1]);
		FindUsefulVsUselessPRes(argv[2], argv[3]);
	}

}

void FindUsefulVsUselessPRes(char *SA, char *SSID)
{
int eFrame=0;	
int nextFrame;
char *success;
int illegalFrames=0;
int totalFrames=0;
int useful=0;
int useless=0;
int prev_count=0;
int curr_count=0;
int prev_added=0;
int totalProbeRequests=0;
int totalProbeResponses=0;
int totalUseful=0;
int totalUseless=0;

//Read SSIDs
char *allowed_ssids;
long input_file_size;
FILE *input_file = fopen(SSID, "r");
fseek(input_file, 0, SEEK_END);
input_file_size = ftell(input_file);
rewind(input_file);
allowed_ssids = malloc((input_file_size + 1) * (sizeof(char)));
fread(allowed_ssids, sizeof(char), input_file_size, input_file);
fclose(input_file);
allowed_ssids[input_file_size] = 0;
//End Read SSIDs
	while(eFrame<framesCount)
	{//Main while

	if(strcmp(PCAP_DATA_VAL[eFrame].wlan_fc_type_subtype,"0x04") == 0 && 
        strcmp(PCAP_DATA_VAL[eFrame+1].wlan_fc_type_subtype,"0x05") == 0)
		{//if check probe request
		int nFrame = eFrame + 1;
		int probeResponse = 0, useful=0, useless=0;
		while((nFrame<framesCount)&&
		     strcmp(SA,PCAP_DATA_VAL[eFrame].wlan_sa) == 0 &&
		     strcmp(PCAP_DATA_VAL[nFrame].wlan_da,PCAP_DATA_VAL[eFrame].wlan_sa) == 0  && 
		     strcmp(PCAP_DATA_VAL[nFrame].wlan_fc_type_subtype,"0x05") == 0)
			{//while check probe responses
				probeResponse ++;
				if (strstr(allowed_ssids, PCAP_DATA_VAL[nFrame].pres.ssid)==NULL)
			        {//2 - I cannot associate to this SSID
				//printf("\n Pres SSID %s, Allowed SSID: %s",PCAP_DATA_VAL[nFrame].pres.ssid, allowed_ssids);

					useless++;
				}///2
				else
				{//3 - Probe response from an SSID to which I can associate
			      
                                   //Check history of probe responses for matching BSSID as in current PRes
	                	   int i=0, match_found=0, change_found=0;
				   for(i=0;i<prev_count;i++)
				   {///6-//If an entry for BSSID is found, then check is there any change in information
				      //If change found then useful, update entry in history
				      //If no change found then useless
				     if(strcmp(PCAP_DATA_VAL[nFrame].pres.bssid,prev_probe_responses[i].bssid)==0)
				     {//7
					match_found=1;
				        //is channel changed?
					//station count changed?
					if((PCAP_DATA_VAL[nFrame].pres.channel!=prev_probe_responses[i].channel)||(PCAP_DATA_VAL[nFrame].pres.station_count!=prev_probe_responses[i].station_count))
					{//8
					  useful++;
					  change_found=1;
					  //update
					  prev_probe_responses[i].channel=PCAP_DATA_VAL[nFrame].pres.channel;
					  prev_probe_responses[i].station_count=PCAP_DATA_VAL[nFrame].pres.station_count;
					  break;
					}//8
			
 				     }//7	
				   }//6

				   if(match_found && !change_found) //Found a match but no change found
					useless++;
				   if(!match_found) //No match found, Useful, Add Entry 
				   {
					useful++;
                                 ///There can be multiple BSSIDs with same SSID therefore we need an array of prev_probe_responses
				        strcpy(prev_probe_responses[prev_count].bssid, PCAP_DATA_VAL[nFrame].pres.bssid);
					prev_probe_responses[prev_count].channel=PCAP_DATA_VAL[nFrame].pres.channel;
					prev_probe_responses[prev_count++].station_count=PCAP_DATA_VAL[nFrame].pres.station_count;
				   }
 
			         }//3

				nFrame ++;
				
			}//while check probe responses
		if(probeResponse > 0){
		printf("%d,%d,%d\n",probeResponse,useless,useful);
		totalProbeRequests++;
		totalProbeResponses=totalProbeResponses+probeResponse;
		totalUseless=totalUseless+useless;
		totalUseful=totalUseful+useful;
		}
		eFrame = nFrame;
		
	}//if check probe request
	else
		eFrame++;
	}//Main While
if(totalProbeRequests>0)
printf("%d,%d,%d,%d\n",totalProbeRequests,totalProbeResponses,totalUseless,totalUseful);

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

//frame.time_epoch -e wlan.fc.type_subtype -e wlan_mgt.ssid -e wlan.bssid -e wlan_mgt.ds.current_channel -e wlan_mgt.qbss.scount -e wlan.fc.retry -e wlan.ra -e wlan.ta -e wlan.sa -e wlan.da -e  wlan.fc.type

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
   		    strcpy(PCAP_DATA_VAL[frame].wlan_fc_type_subtype, token);

		    token = strtok(NULL, ",");
		    if (token != NULL && !(strcmp(token, "EMPTY") == 0 ))
   		    strcpy(PCAP_DATA_VAL[frame].pres.ssid, token);
		
		    token = strtok(NULL, ",");
		    if (token != NULL && !(strcmp(token, "EMPTY") == 0 ))
   		    strcpy(PCAP_DATA_VAL[frame].pres.bssid, token);		    
		
		    token = strtok(NULL, ",");
		    if (token != NULL && !(strcmp(token, "EMPTY") == 0 ))
   		    PCAP_DATA_VAL[frame].pres.channel =  atoi(token);

		    token = strtok(NULL, ",");
		    if (token != NULL && !(strcmp(token, "EMPTY") == 0 ))
   		    PCAP_DATA_VAL[frame].pres.station_count =  atoi(token);

                    token = strtok(NULL, ",");
		    if (token != NULL && !(strcmp(token, "EMPTY") == 0 ))
   		    strcpy(PCAP_DATA_VAL[frame].wlan_ra, token);			

		    token = strtok(NULL, ",");
		    if (token != NULL && !(strcmp(token, "EMPTY") == 0 ))
   		    strcpy(PCAP_DATA_VAL[frame].wlan_ta, token);


		    token = strtok(NULL, ",");
		    if (token != NULL && !(strcmp(token, "EMPTY") == 0 ))
   		    strcpy(PCAP_DATA_VAL[frame].wlan_sa, token);

		    token = strtok(NULL, ",");
		    if (token != NULL && !(strcmp(token, "EMPTY") == 0 ))
   		    strcpy(PCAP_DATA_VAL[frame].wlan_da, token);

    
		    token = strtok(NULL, ",");
		    if (token != NULL && !(strcmp(token, "EMPTY") == 0 ))
   		    PCAP_DATA_VAL[frame].type = atoi(token);

		}
		framesCount=frame;
		fclose(file);

}

