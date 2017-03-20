"""
Authors:
  
  Jeffrey Meyers
  Ruben Niculcea

Date:
  
  June 7, 2014

Purpose:
  
  Extra credit assignment for CS 311 - Computational Structures
  taught by Daniel Leblanc at Portland State University.

  Implement a program takes as input an encoding of a DFA machine and a string
  and states whether the string is a member of the language defined
  by that machine.

Description:
  
  1. The DFA class is intialized with a path to an encoding of a DFA as JSON.

  2. The JSON is parsed into the 5 parts required to define a DFA in addition
  to a description of the machine and an array containing test inputs.

  3. The machine and test inputs are returned after parsing.

  4. The machine runs on each input and prints the transitions taken
  and after all characters are consumed prints whether it is in an ACCEPT
  state.

"""

import json
import pdb
import sys
import csv

DESC = "description"
STATE = "states"
START = "start"
ALPHA = "alphabet"
TRANS = "transitions"
ACCEPT = "accept"
INPUTS = "inputs"


class DFA:
    states = None
    alphabet = None
    description = None
    start_state = None
    accept_states = None
    # {State : {input : newState}}
    transitions = None
    input_strings = None 
    cause= None
    def __init__(self, file_name):
        
	#print file_name
        dfa = json.load(open(file_name))
        self.states = dfa[STATE]
        self.alphabet = dfa[ALPHA]
        self.description = dfa[DESC]
        self.start_state = dfa[START]
        self.accept_states = dfa[ACCEPT]
        self.transitions = dfa[TRANS]
        self.input_strings = dfa[INPUTS]

    def get_signatures(self, file_name):
       signatures = json.load(open(file_name))
       self.input_strings = signatures[INPUTS]
       return self.input_strings

    def get_dfa(self):
    	return self, self.input_strings

    def run_dfa(self, input_str):
	previous_state = "Unknown"
        current_state = self.start_state
        #print "Running the DFA with the description:"
        #print self.description
        #print "On the input: " + input_str
	flow=""
        for char in input_str:
	    #print current_state, char
	    
            if current_state in self.accept_states:
                break

            if current_state not in self.transitions:
                #print "Invalid DFA: " + current_state + " is not a state in the DFA."
                break

            if char not in self.transitions[current_state]:
                #print "Invalid DFA: " + char + " does not transition to a state in the DFA."
                break

            new_state = self.transitions[current_state][char]
	    flow=flow +"->"+ new_state
	    previous_state = current_state
            current_state = new_state
	#print flow
	if ("Unknown->Scanning" in flow):
		cause="UnassociatedandPeriodic" 
	elif ("Unassociated->Scanning" in flow):
		cause="UnassociatedandPeriodic"  #1
	elif ("Unassociated->Associated->Scanning" in flow or "Unassociated->Associated->Active->Scanning" in flow):
		cause="ConnectionEstablishment" #2
	elif ("PowerSave->Active->Scanning" in flow or "PowerSave->Active->PowerSave->Scanning" in flow):
		cause="PowerManagement" #3
	elif ("Active->Scanning" in flow):
		cause="AssociatedandPeriodic" 
	elif ("CMM->Scanning" in flow):
		cause="AP-STA-Management" #4
	elif ("PowerSave->Scanning" in flow):
		cause="AssociatedandPeriodic" 
	elif ("BM->Scanning" in flow):
		if (char == "L"):
			cause="BeaconLosses" #5
		else:
			cause="AssociatedandPeriodic" 
	elif ("Moving->Scanning" in flow):
		cause="SignalStrength" #6
	elif ("CQM->Scanning" in flow):
		cause="FrameLosses" #7
	elif ("Associated->Scanning" in flow):
		cause="AssociatedandPeriodic" 
	elif ("NoScanning" in flow):
		cause="NoScanning"
 	else:
		cause="Unidentified"

	#print input_str.rstrip('\n') +","+ cause
	print cause
        

if __name__ == "__main__":
    
    signatureFile=sys.argv[1]
    jsonFile=sys.argv[2]
    dfa, input_strings = DFA(jsonFile).get_dfa()
    
    #input_strings = dfa.get_signatures(string_file)
    #print input_strings
    with open(signatureFile) as sFile:
    	signatures = sFile.readlines()

    for s in signatures:
    	dfa.run_dfa(s)

