PROGRAM _INIT
	(* Initializing function blocks and their inputs *)
	AsmPowerOn.Assembly := ADR(gAssembly_1);
	AsmPowerOff.Assembly := ADR(gAssembly_1);
	AsmGetShuttle.Assembly := ADR(gAssembly_1);
	AsmStop.Assembly := ADR(gAssembly_1);
	AsmStop.StopMode := mcSTOPMODE_JERK_LIMIT;
	AsmReadStatus.Assembly := ADR(gAssembly_1);
	AsmReadStatus.Enable := TRUE;
	
	(* Initializing parameters for shuttle movements *)
	gTrakAsm.Parameter := SHUTTLE_PARAMETERS;
END_PROGRAM

PROGRAM _CYCLIC
	IF gTrakAsm.Status.ErrorStop THEN
		Step := ERROR;
	END_IF
	
	CASE Step OF
		
		POWER_OFF:
			IF gTrakAsm.Status.Disabled THEN
				AsmPowerOff.Execute := FALSE;
				Step := POWERED_OFF;
			END_IF
			
		WAIT_POWER_OFF:
			
		POWERED_OFF:
			IF gTrakAsm.Command.PowerOn AND gTrakAsm.Status.Disabled THEN
				AsmPowerOn.Execute := TRUE;
				Step := POWER_ON;
			END_IF
			
		POWER_ON:
			IF AsmPowerOn.Done AND gTrakAsm.Status.Ready THEN
				AsmPowerOn.Execute := FALSE;
				FOR i := 1 TO MAX_SHUTTLE_CNT BY 1 DO
					brsmemset(ADR(ShuttleList[i].ShuttleReference), 0, SIZEOF(ShuttleList[i].ShuttleReference));
				END_FOR
				CurrentShuttleNumber := 1;
				Step := GET_SHUTTLE;
			END_IF
			
		WAIT_POWER_ON:
			
		GET_SHUTTLE:
			AsmGetShuttle.Enable := TRUE;

			IF AsmGetShuttle.Valid THEN
				(* There are no shuttles on the assembly. *)
				IF AsmGetShuttle.TotalCount = 0 THEN
					gTrakAsm.ShuttleCnt := 0;
					AsmGetShuttle.Enable := FALSE;
					AsmGetShuttle.Next := FALSE;

					Step := READY;
                (* As soon as the next shuttle has been output by the function block, RemainingCount
                   is reduced and this condition becomes true. *)
				ELSIF (AsmGetShuttle.RemainingCount <> (AsmGetShuttle.TotalCount - CurrentShuttleNumber)) THEN
					CurrentShuttleNumber := CurrentShuttleNumber + 1;
					AsmGetShuttle.Next := FALSE;
				ELSE
					(* Store all axis references in an array for global movement commands. *)
					ShuttleList[CurrentShuttleNumber].ShuttleReference := AsmGetShuttle.Axis;
					(* Get next shuttle reference with positive edge on .Next. *)
					AsmGetShuttle.Next := TRUE;
                
					(* All shuttles have been stored. *)
					IF (AsmGetShuttle.RemainingCount = 0) THEN
						gTrakAsm.ShuttleCnt := AsmGetShuttle.TotalCount;
						AsmGetShuttle.Enable := FALSE;
						AsmGetShuttle.Next := FALSE;
                        
						Step := READY;
					END_IF
				END_IF
			END_IF
			
		READY:
			
		START_MOVEMENT:
			
		WAIT_START_MOVEMENT:
			
		MOVING:
			
		STOPPING:
			
		WAIT_STOPPING:
			
		ERROR:
			
		RESET:
			
	END_CASE
	
	(* Read assembly status cyclically to assembly interface. *)
	gTrakAsm.Status.Disabled := AsmReadStatus.AssemblyDisabled;
	gTrakAsm.Status.Ready := AsmReadStatus.AssemblyReady;
	gTrakAsm.Status.Homing := AsmReadStatus.AssemblyHoming;
	gTrakAsm.Status.Stopping := AsmReadStatus.AssemblyStopping;
	gTrakAsm.Status.ErrorStop := AsmReadStatus.AssemblyErrorStop;
	
	(* Calling function blocks *)
	AsmPowerOn();
	AsmPowerOff();
	AsmGetShuttle();
	AsmStop();
	AsmReadStatus();
	FOR i := 1 TO MAX_SHUTTLE_CNT BY 1 DO
		IF ShuttleList[i].ShuttleReference.controlif <> 0 THEN
			ShuttleList[i].RoutedMoveVel();
		END_IF
	END_FOR
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	
END_PROGRAM