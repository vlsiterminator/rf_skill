;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RF Generator V0.1
;; Ningxi Liu
;; Module: RF_Sel_Bank_single
;; 2014/11/12
;; V0.1 Modification:
;; 1) Added a WL_driver, which is controlled by BANK_SEL
;; 2) Supported DIN<wordsize-1:0> to be independent pins.
;; V0.2:
;; 1) RF_Sel_Bank_single is used to create bitcell with single read BL.
;; 2) Bitcell, Colmux, SA instances are updated.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load the file containing the basic schematic procedures
load("./skill/ece432Schematic.il")
/*====================================================================
 Define the procedure for creating schematic of a RF column with one bitcell selected in NROW bitcells
 This procedure has 4 parameter:
 - libName: the name of the library that you will put the cell schematic in;
 - cellName: the name of the cell you will create;
 - NROW: the number of rows;
 - bcType: 6T or 8T cell;
=====================================================================*/
procedure(RF(libName cellName NROW NCol_Mux Wordsize bcType)

  ;; Define the local variables
  prog((cvid x y pin pinName WLName i j k cnt WL RWL BitcellName unSel_Col_Name inst inputsignal)
    
	sprintf(BitcellName "Bitcell_%s_single" bcType)
        sprintf(unSel_Col_Name "unSel_Col_%s_single" bcType)
    printf("%L %L\n" BitcellName unSel_Col_Name)
    
 ;; Open the cell and its schematic view
    cvid = dbOpenCellViewByType(libName cellName "schematic" "schematic" "a")
	
	;; Clean the schematic view
    ece432DeleteObjectsSchematic(cvid)
	
	;; The coordinate of the origin point for the schematic
    x=0
    y=0
	
;; Create top level pins
;; Create input pins
    foreach(pinName list("VDD" "VSS" "WL_IN" "RWL_IN" sprintf(nil "DIN<%L:0>" Wordsize-1) "CSEL_IN" "CSELB_IN" "CSEL_RBL_IN" "CSELB_RBL_IN" "PCH_IN" "PCH_RBL_IN" "WEN_IN" "BANK_SEL_IN" "BANK_SELB_IN" "BANK_SEL_WL" "BANK_SEL_RWL")
      pin=ece432SchematicCreatePin(cvid pinName "input" x:y "R0")
      y=y+0.5
    )
	;; Create output pins
    
    foreach(pinName list(sprintf(nil "DOUT<%L:0>" Wordsize-1))
	pin=ece432SchematicCreatePin(cvid pinName "output" x:y "R0")
	y=y+0.5
	)
printf("pin set done")
;; To create input buffer for stimuli
;; WL has an unique WL driver
    foreach(WLName list("WL" "RWL")
	y=y+2
	inst = ece432SchematicCreateInst(
	           	   ;; Cell view id
			   cvid 
			   
			   ;; Name of the library containing the bitcell
			   libName
			   
	           	   ;; The bitcell name  
              		   "WL_driver"  
			   
			   ;; Cell view type, always be "symbol" here
			   "symbol" 
			   
			   ;; Instance name
	                   sprintf(nil "%s_driver0" WLName)
			   
			   ;; The following list defines the connections of the left side pins 
			   ;; in the symbol view; For our bitcell, 'VDD' 'VSS' 'BL' are pins on the left.
			   ;; The inverter pin 'WL' is connected with the net WL.
			   ;; If there are multiple pins on the left side, you can use the below way to define.
			   ;;    list(list("in1" in1net)
			   ;;         list("in2" in2net))
			   ;; If there is no pin on the left side, this parameter should be 'nil'.
	           list(list("VDD" "VDD")
			list("VSS" "VSS")
			list("IN" sprintf(nil "%s_IN" WLName) )   
			list("EN" sprintf(nil "BANK_SEL_%s" WLName) ))   
			   ;; The following list defines the connections of the right side pins 
			   ;; in the symbol view; For our bitcell, 'BLB' is the only pin on the right.
	  		   list(list("OUT" WLName ))  
			   
			   ;; The following list defines the connections of the top side pins 
			   
      		   nil
			   
			   ;; The following list defines the connections of the bottom side pins 
			   ;; in the symbol view; For this buffer, this parameter should be 'nil'.
	           nil
			   
			   ;; Location of the instance
                   x:y 
			   
			   ;; Rotation of the instance, such as "R0", "R90", "R180", "R270", "MX", "MY", ...
		   "R0"
			 ) ;; end inst  
    );end foreach WL RWL  

;; create buffer for other signals
    y=y+1
    cnt=1
    foreach(inputsignal list("CSEL" "CSELB" "CSEL_RBL" "CSELB_RBL" "PCH" "PCH_RBL" "WEN" "BANK_SEL" "BANK_SELB")
	inst = ece432SchematicCreateInst(
	           	   ;; Cell view id
			   cvid 
			   
			   ;; Name of the library containing the bitcell
			   libName
			   
	           	   ;; The bitcell name  
              		   "inv_chain"  
			   
			   ;; Cell view type, always be "symbol" here
			   "symbol" 
			   
			   ;; Instance name
	           sprintf(nil "Buffer_%d" cnt) 
			   
			   ;; The following list defines the connections of the left side pins 
			   ;; in the symbol view; For our bitcell, 'VDD' 'VSS' 'BL' are pins on the left.
			   ;; The inverter pin 'WL' is connected with the net WL.
			   ;; If there are multiple pins on the left side, you can use the below way to define.
			   ;;    list(list("in1" in1net)
			   ;;         list("in2" in2net))
			   ;; If there is no pin on the left side, this parameter should be 'nil'.
	           list(list("VDD" "VDD")
			list("VSS" "VSS")
			list("IN" sprintf(nil "%s_IN" inputsignal)) )   
			   
			   ;; The following list defines the connections of the right side pins 
			   ;; in the symbol view; For our bitcell, 'BLB' is the only pin on the right.
	  		   list(list("OUT" inputsignal ))  
			   
			   ;; The following list defines the connections of the top side pins 
			   
      		   nil
			   
			   ;; The following list defines the connections of the bottom side pins 
			   ;; in the symbol view; For this buffer, this parameter should be 'nil'.
	           nil
			   
			   ;; Location of the instance
                   x:y 
			   
			   ;; Rotation of the instance, such as "R0", "R90", "R180", "R270", "MX", "MY", ...
		   "R0"
			 ) ;; end inst
	y=y+1
	cnt=cnt+1
	) ;;end foreach inputsignal

;; Loop for replicating NROW*NCol_Mux bitcells with Wordsize times
    for(i 1 Wordsize
	;; The coordinate of the origin point for the schematic
    x=x+3
    y=0
	
;; Loop for replicating bitcells with NROW times
    for(k 1 NROW	  
	  ;; Instantiate the kth bitcell with ece432SchematicCreateInst() procedure, 
	  ;; which is defined in the file 'ece432Schematic.il'. 
;; Assign the first WL with WL, while other WLs are assigned VSS
if(k==1 then
	WL = "WL"
else
	WL = "VSS"
);;end if WL
;; Assign the second RWL with RWL, while other RWLs are assigned VSS.
;; RWL and WL are in different rows because read and write shouldn't occur to the same row.
if(k==2 then
	RWL = "RWL"
else
	RWL = "VSS"
);;end if WL
;;Create instance for Bitcell
      inst = ece432SchematicCreateInst(
	           	   ;; Cell view id
			   cvid 
			   
			   ;; Name of the library containing the bitcell
			   libName
			   
	           	   ;; The bitcell name  
              		   BitcellName  
			   
			   ;; Cell view type, always be "symbol" here
			   "symbol" 
			   
			   ;; Instance name
	           sprintf(nil "Bitcell_Col%L_Row%L" NCol_Mux*(i-1) k-1) 
			   
			   ;; The following list defines the connections of the left side pins 
			   ;; in the symbol view; For our bitcell, 'VDD' 'VSS' 'BL' are pins on the left.
			   ;; The inverter pin 'WL' is connected with the net WL.
			   ;; If there are multiple pins on the left side, you can use the below way to define.
			   ;;    list(list("in1" in1net)
			   ;;         list("in2" in2net))
			   ;; If there is no pin on the left side, this parameter should be 'nil'.
	           list(list("VDD" "VDD")
			list("VSS" "VSS")
			list("BL" sprintf(nil "BL%L" NCol_Mux*(i-1)) ))   
			   
			   ;; The following list defines the connections of the right side pins 
			   ;; in the symbol view; For our bitcell, 'BLB' is the only pin on the right.
	  	   list(list("BLB" sprintf(nil "BLB%L" NCol_Mux*(i-1)) )
                        list("RBL" sprintf(nil "RBL%L" NCol_Mux*(i-1)) ))  
			   
			   ;; The following list defines the connections of the top side pins 
			   
      		   list(list("WL"  WL )
                        list("RWL"  RWL ))
			   
			   ;; The following list defines the connections of the bottom side pins 
			   ;; in the symbol view; For our bitcell, this parameter should be 'nil'.
	           nil
			   
			   ;; Location of the instance
                   x:y 
			   
			   ;; Rotation of the instance, such as "R0", "R90", "R180", "R270", "MX", "MY", ...
		   "R0"
			 );; end inst 
        
	  ;; The next inverter will be put at the right side of the current one.   
	  y=y-2
	  
    );; end for(k
printf("column cell set")
;;To add column mux
	y=y-3
	inst = ece432SchematicCreateInst(
	           	   ;; Cell view id
			   cvid 
			   
			   ;; Name of the library containing the bitcell
			   libName
			   
	           	   ;; column mux cellview  
              		   "Col_Mux_single" 
			   
			   ;; Cell view type, always be "symbol" here
			   "symbol" 
			   
			   ;; Instance name
	                   sprintf(nil "Col_Mux_inst%L" i-1)
			   
			   ;; The following list defines the connections of the left side pins 
			   ;; in the symbol view; For our bitcell, 'VDD' 'VSS' 'BL' are pins on the left.
			   ;; The inverter pin 'WL' is connected with the net WL.
			   ;; If there are multiple pins on the left side, you can use the below way to define.
			   ;;    list(list("in1" in1net)
			   ;;         list("in2" in2net))
			   ;; If there is no pin on the left side, this parameter should be 'nil'.
	           list(list("CSEL" "CSEL")
			list("CSELB" "CSELB")
                        list("CSEL_RBL" "CSEL_RBL")
			list("CSELB_RBL" "CSELB_RBL")
			list("PCH" "PCH")
                        list("PCH_RBL" "PCH_RBL")
			list("VDD" "VDD")
			list("VSS" "VSS"))
			
			   ;; The following list defines the connections of the right side pins
	  	   nil  
			   
			   ;; The following list defines the connections of the top side pins 
			   
      		   list(list("BL"  sprintf(nil "BL%L" NCol_Mux*(i-1)) )
			list("BLB"  sprintf(nil "BLB%L" NCol_Mux*(i-1)) )
                        list("RBL"  sprintf(nil "RBL%L" NCol_Mux*(i-1)) ))
			   
			   ;; The following list defines the connections of the bottom side pins 
			   
	           list(list("RDWR"  sprintf(nil "RDWR%L" i-1) )
			list("NRDWR"  sprintf(nil "NRDWR%L" i-1) )
                        list("RBL_COL"  sprintf(nil "RBL_COL%L" i-1) ))
			   
			   ;; Location of the instance
                   x:y 
			   
			   ;; Rotation of the instance, such as "R0", "R90", "R180", "R270", "MX", "MY", ...
		   "R0"
			 );; end inst
;; To add SA
	y=y-3
	inst = ece432SchematicCreateInst(
	           	   ;; Cell view id
			   cvid 
			   
			   ;; Name of the library containing the bitcell
			   libName
			   
	           	   ;; column mux cellview  
              		   "SA_single" 
			   
			   ;; Cell view type, always be "symbol" here
			   "symbol" 
			   
			   ;; Instance name
	                   sprintf(nil "SA_inst%L" i-1)
			   
			   ;; The following list defines the connections of the left side pins 
			   ;; in the symbol view; For our bitcell, 'VDD' 'VSS' 'BL' are pins on the left.
			   ;; The inverter pin 'WL' is connected with the net WL.
			   ;; If there are multiple pins on the left side, you can use the below way to define.
			   ;;    list(list("in1" in1net)
			   ;;         list("in2" in2net))
			   ;; If there is no pin on the left side, this parameter should be 'nil'.
	           list(
			list("VDD" "VDD")
			list("VSS" "VSS")  
			list("WEN" "WEN")
			list("DIN" sprintf(nil "DIN<%L>" i-1) )
                        list("RBL_COL"  sprintf(nil "RBL_COL%L" i-1) ))
			
			   ;; The following list defines the connections of the right side pins
	  	   list(list("RBL_BM"  sprintf(nil "DOUT_SA%L" i-1) )  )
			   
			   ;; The following list defines the connections of the top side pins 
			   
      		   list(list("RDWR"  sprintf(nil "RDWR%L" i-1) )
			list("NRDWR"  sprintf(nil "NRDWR%L" i-1) ))
			   
			   ;; The following list defines the connections of the bottom side pins 
			   ;; in the symbol view; For our bitcell, this parameter should be 'nil'.
	           nil
			   
			   ;; Location of the instance
                   x:y 
			   
			   ;; Rotation of the instance, such as "R0", "R90", "R180", "R270", "MX", "MY", ...
		   "R0"
			 );; end inst

;;To add bank mux after each SA output
	y=y-3
	inst = ece432SchematicCreateInst(
	           	   ;; Cell view id
			   cvid 
			   
			   ;; Name of the library containing the bitcell
			   libName
			   
	           	   ;; column mux cellview  
              		   "Bank_Mux" 
			   
			   ;; Cell view type, always be "symbol" here
			   "symbol" 
			   
			   ;; Instance name
	                   sprintf(nil "BM_inst%L" i-1)
			   
			   ;; The following list defines the connections of the left side pins 
			   ;; in the symbol view; For our bitcell, 'VDD' 'VSS' 'BL' are pins on the left.
			   ;; The inverter pin 'WL' is connected with the net WL.
			   ;; If there are multiple pins on the left side, you can use the below way to define.
			   ;;    list(list("in1" in1net)
			   ;;         list("in2" in2net))
			   ;; If there is no pin on the left side, this parameter should be 'nil'.
	           list(list("BANK_SEL" "BANK_SEL")
			list("BANK_SELB" "BANK_SELB")
			list("VDD" "VDD")
			list("VSS" "VSS") 
			list("DIN" sprintf(nil "DOUT_SA%L" i-1) ) )
			
			   ;; in the symbol view; For our bitcell, 'BLB' is the only pin on the right.
	  	   list(list("DOUT"  sprintf(nil "DOUT<%L>" i-1) )  )
			   
			   ;; The following list defines the connections of the top side pins 
			   ;; in the symbol view; For our inverter, 'VDD' is the only pin on the top.
      		   nil
			   
			   ;; The following list defines the connections of the bottom side pins 
			   ;; in the symbol view; For our bitcell, this parameter should be 'nil'.
	           nil
			   
			   ;; Location of the instance
                   x:y 
			   
			   ;; Rotation of the instance, such as "R0", "R90", "R180", "R270", "MX", "MY", ...
		   "R0"
			 );; end inst

printf("column mux set")
	;; To add unselected column
	
	
	for(j 1 NCol_Mux-1
	x=x+3
	y=0
	inst = ece432SchematicCreateInst(
	           	   ;; Cell view id
			   cvid 
			   
			   ;; Name of the library containing the bitcell
			   libName
			   
	           	   ;; column mux cellview  
              		   unSel_Col_Name 
			   
			   ;; Cell view type, always be "symbol" here
			   "symbol" 
			   
			   ;; Instance name
	                   sprintf(nil "Col_%L" j+NCol_Mux*(i-1))
			   
			   ;; The following list defines the connections of the left side pins 
			   ;; in the symbol view; For our bitcell, 'VDD' 'VSS' 'BL' are pins on the left.
			   ;; The inverter pin 'WL' is connected with the net WL.
			   ;; If there are multiple pins on the left side, you can use the below way to define.
			   ;;    list(list("in1" in1net)
			   ;;         list("in2" in2net))
			   ;; If there is no pin on the left side, this parameter should be 'nil'.
	           list(list("WL" "WL")
			list("PCH" "PCH")
                        list("RWL" "RWL")
			list("PCH_RBL" "PCH_RBL")
			list("VDD" "VDD")
			list("VSS" "VSS"))
			
			   ;; in the symbol view; For our bitcell, 'BLB' is the only pin on the right.
	  	   nil  
			   
			   ;; The following list defines the connections of the top side pins 
		   nil
			   
			   ;; The following list defines the connections of the bottom side pins 
			   ;; in the symbol view; For our bitcell, this parameter should be 'nil'.
	           list(list("RDWR"  sprintf(nil "RDWR%L" i-1))
			list("NRDWR"  sprintf(nil "NRDWR%L" i-1))
                        list("RBL_COL"  sprintf(nil "RBL_COL%L" i-1)) )
			   
			   ;; Location of the instance
                   x:y 
			   
			   ;; Rotation of the instance, such as "R0", "R90", "R180", "R270", "MX", "MY", ...
			   "R0"
			 );; end inst
		
	);; end for j in NCol_Mux
        );; end for i in Wordsize



	;; Check, save and close the cell view
	schCheck(cvid)  ;; check the schematic connectivity
    dbSave(cvid)
    dbClose(cvid)
	
    return(t)
	
  );; end prog
  
);; end procedure


/*====================================================================
 'let' is the main entrance of the skill program.
 We will build schematic for a 6-bit inverter chain as an example.
====================================================================*/
let((NRow NCol_Mux Wordsize libName cellName bcType)  ;; N, libName and cellName are variables

  ;; The number of inverters
  NRow = 64 
  NCol_Mux = 1
  Wordsize = 16
  ;; The name of the library we will put the new cell in
  libName="Register_File"
printf("for debug1")
  ;; Input bitcell type
  bcType = "12T2r2w"
  
  ;; Define the cell name as 'invChain_6b'
  sprintf(cellName "RF_%s_Rowx%L_Colx%Lb" bcType NRow NCol_Mux*Wordsize)
printf("for debug2")
  ;; Call the procedure to create the inverter chain schematic
  RF(libName cellName NRow NCol_Mux Wordsize bcType)
  
  printf("=== Cell %L Schematic has been created! ===\n", cellName)

) ;;end let
