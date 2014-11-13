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
  prog((cvid x y pin pinName i j k cnt WL BitcellName inst inputsignal)
    if(bcType == "6T" then
	BitcellName= "Bitcell_6T"
    else
	BitcellName= "Bitcell_8T"
    );; end if to choose bitcell type
 ;; Open the cell and its schematic view
    cvid = dbOpenCellViewByType(libName cellName "schematic" "schematic" "a")
	
	;; Clean the schematic view
    ece432DeleteObjectsSchematic(cvid)
	
	;; The coordinate of the origin point for the schematic
    x=0
    y=0
	
    ;; Create top level pins
	;; Create input pins
    foreach(pinName list("VDD" "VSS" "WL_IN" "CSEL_IN" "CSELB_IN" "PCH_IN" "SAE_IN" "SAPCH_IN" "DIN_IN" "WEN_IN" "BANK_SEL_IN" "BANK_SELB_IN")
      pin=ece432SchematicCreatePin(cvid pinName "input" x:y "R0")
      y=y+0.5
    )
	;; Create output pins
    
    foreach(pinName list(sprintf(nil "DOUT<%L:0>" Wordsize-1))
	pin=ece432SchematicCreatePin(cvid pinName "output" x:y "R0")
	y=y+0.5
	)
printf("pin set")
;; To create input buffer for stimuli
    y=y+1
    cnt=1
    foreach(inputsignal list("WL" "CSEL" "CSELB" "PCH" "SAE" "SAPCH" "DIN" "WEN" "BANK_SEL" "BANK_SELB")
	
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
			   ;; in the symbol view; For our inverter, 'VDD' is the only pin on the top.
      		   nil
			   
			   ;; The following list defines the connections of the bottom side pins 
			   ;; in the symbol view; For our bitcell, this parameter should be 'nil'.
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
	
	  ;; Define the WL of selected and unselected bitcell
      if(k==1 then
	    WL="WL"	  
      else 
	    WL="VSS"
	);; end if(k==NROW
	  
	  ;; Instantiate the kth bitcell with ece432SchematicCreateInst() procedure, 
	  ;; which is defined in the file 'ece432Schematic.il'. 
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
	           sprintf(nil "Bitcell_Col%L_Row%L" NCol_Mux*(i-1) k) 
			   
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
	  		   list(list("BLB" sprintf(nil "BLB%L" NCol_Mux*(i-1)) ))  
			   
			   ;; The following list defines the connections of the top side pins 
			   ;; in the symbol view; For our inverter, 'VDD' is the only pin on the top.
      		   list(list("WL"  WL))
			   
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
              		   "Col_Mux" 
			   
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
			list("PCH" "PCH")
			list("VDD" "VDD")
			list("VSS" "VSS"))
			
			   ;; in the symbol view; For our bitcell, 'BLB' is the only pin on the right.
	  	   nil  
			   
			   ;; The following list defines the connections of the top side pins 
			   ;; in the symbol view; For our inverter, 'VDD' is the only pin on the top.
      		   list(list("BL"  sprintf(nil "BL%L" NCol_Mux*(i-1)) )
			list("BLB"  sprintf(nil "BLB%L" NCol_Mux*(i-1)) ))
			   
			   ;; The following list defines the connections of the bottom side pins 
			   ;; in the symbol view; For our bitcell, this parameter should be 'nil'.
	           list(list("RDWR"  sprintf(nil "RDWR<%L>" i-1) )
			list("NRDWR"  sprintf(nil "NRDWR<%L>" i-1) ))
			   
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
              		   "SA" 
			   
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
	           list(list("SAE" "SAE")
			list("SAPCH" "SAPCH")
			list("VDD" "VDD")
			list("VSS" "VSS")  
			list("WEN" "WEN")
			list("DIN" "DIN") )
			
			   ;; in the symbol view; For our bitcell, 'BLB' is the only pin on the right.
	  	   list(list("SD"  sprintf(nil "DOUT_SA<%L>" i-1) )  )
			   
			   ;; The following list defines the connections of the top side pins 
			   ;; in the symbol view; For our inverter, 'VDD' is the only pin on the top.
      		   list(list("RDWR"  sprintf(nil "RDWR<%L>" i-1) )
			list("NRDWR"  sprintf(nil "NRDWR<%L>" i-1) ))
			   
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
			list("DIN" sprintf(nil "DOUT_SA<%L>" i-1) ) )
			
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
              		   "unSel_Col" 
			   
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
			list("VDD" "VDD")
			list("VSS" "VSS"))
			
			   ;; in the symbol view; For our bitcell, 'BLB' is the only pin on the right.
	  	   nil  
			   
			   ;; The following list defines the connections of the top side pins 
		   nil
			   
			   ;; The following list defines the connections of the bottom side pins 
			   ;; in the symbol view; For our bitcell, this parameter should be 'nil'.
	           list(list("RDWR"  sprintf(nil "RDWR<%L>" i-1))
			list("NRDWR"  sprintf(nil "NRDWR<%L>" i-1)))
			   
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
  NCol_Mux = 4
  Wordsize = 16
  ;; The name of the library we will put the new cell in
  libName="Register_File"
printf("for debug1")
  ;; Input bitcell type
  bcType = "6T"
  
  ;; Define the cell name as 'invChain_6b'
  sprintf(cellName "RF_Rowx%L_Colx%Lb" NRow NCol_Mux*Wordsize)
printf("for debug2")
  ;; Call the procedure to create the inverter chain schematic
  RF(libName cellName NRow NCol_Mux Wordsize bcType)
  
  printf("=== Cell %L Schematic has been created! ===\n", cellName)

) ;;end let
