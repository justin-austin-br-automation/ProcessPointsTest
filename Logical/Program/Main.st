PROGRAM _INIT
	(* Initializing function blocks and their inputs *)
	AsmPowerOn.Assembly := ADR(gAssembly_1);
	AsmPowerOff.Assembly := ADR(gAssembly_1);
	AsmGetShuttle.Assembly := ADR(gAssembly_1);
	AsmStop.Assembly := ADR(gAssembly_1);
	AsmStop.StopMode := mcSTOPMODE_JERK_LIMIT;
	AsmReadStatus.Assembly := ADR(gAssembly_1);
	AsmReadStatus.Enable := TRUE;
	
	BufferBarrier.Command.ProcessPoint := ADR(BufferZone);
	BufferBarrier.GetShuttle.ProcessPoint := ADR(BufferZone);
	BufferBarrier.ReadInfo.ProcessPoint := ADR(BufferZone);
	BufferBarrier.Command.Command := mcACPTRAK_BARRIER_OPEN;
	BufferBarrier.Command.Execute := TRUE;
	BufferBarrier.Command();
	
	WorkZone.Command.ProcessPoint := ADR(Station0);
	WorkZone.GetShuttle.ProcessPoint := ADR(Station0);
	WorkZone.ReadInfo.ProcessPoint := ADR(Station0);
	WorkZone.Command.Command := mcACPTRAK_BARRIER_OPEN;
	WorkZone.Command.Execute := TRUE;
	WorkZone.Command();
	
	WorkStation1.Command.ProcessPoint := ADR(Station1);
	WorkStation1.GetShuttle.ProcessPoint := ADR(Station1);
	WorkStation1.GetShuttle.Enable := TRUE;
	WorkStation1.ReadInfo.ProcessPoint := ADR(Station1);
	WorkStation1.Command.Command := mcACPTRAK_BARRIER_CLOSE;
	WorkStation1.Command.Execute := TRUE;
	WorkStation1.Command();
	
	WorkStation2.Command.ProcessPoint := ADR(Station2);
	WorkStation2.GetShuttle.ProcessPoint := ADR(Station2);
	WorkStation2.GetShuttle.Enable := TRUE;
	WorkStation2.ReadInfo.ProcessPoint := ADR(Station2);
	WorkStation2.Command.Command := mcACPTRAK_BARRIER_CLOSE;
	WorkStation2.Command.Execute := TRUE;
	WorkStation2.Command();
	
	WorkStation3.Command.ProcessPoint := ADR(Station3);
	WorkStation3.GetShuttle.ProcessPoint := ADR(Station3);
	WorkStation3.GetShuttle.Enable := TRUE;
	WorkStation3.ReadInfo.ProcessPoint := ADR(Station3);
	WorkStation3.Command.Command := mcACPTRAK_BARRIER_CLOSE;
	WorkStation3.Command.Execute := TRUE;
	WorkStation3.Command();
	
	WorkStation4.Command.ProcessPoint := ADR(Station4);
	WorkStation4.GetShuttle.ProcessPoint := ADR(Station4);
	WorkStation4.GetShuttle.Enable := TRUE;
	WorkStation4.ReadInfo.ProcessPoint := ADR(Station4);
	WorkStation4.Command.Command := mcACPTRAK_BARRIER_CLOSE;
	WorkStation4.Command.Execute := TRUE;
	WorkStation4.Command();
	
	MaintenanceStation.Command.ProcessPoint := ADR(MaintenancePoint);
	MaintenanceStation.GetShuttle.ProcessPoint := ADR(MaintenancePoint);
	MaintenanceStation.ReadInfo.ProcessPoint := ADR(MaintenancePoint);
	MaintenanceStation.Command.Command := mcACPTRAK_BARRIER_CLOSE;
	MaintenanceStation.Command.Execute := TRUE;
	MaintenanceStation.Command();
	
	ThroughputStation.Command.ProcessPoint := ADR(Throughput);
	ThroughputStation.GetShuttle.ProcessPoint := ADR(Throughput);
	ThroughputStation.ReadInfo.ProcessPoint := ADR(Throughput);
	ThroughputStation.Command.Command := mcACPTRAK_BARRIER_OPEN;
	ThroughputStation.Command.Execute := TRUE;
	ThroughputStation.Command();
	
	(* Initializing parameters for shuttle movements *)
	gTrakAsm.Parameter := SHUTTLE_PARAMETERS;
END_PROGRAM

PROGRAM _CYCLIC
	IF gTrakAsm.Status.ErrorStop THEN
		Step := ERROR;
	END_IF
	
	CASE Step OF
		
		POWER_OFF:
			BufferBarrier.Command.Execute := FALSE;
			WorkZone.Command.Execute := FALSE;
			WorkStation1.Command.Execute := FALSE;
			WorkStation2.Command.Execute := FALSE;
			WorkStation3.Command.Execute := FALSE;
			WorkStation4.Command.Execute := FALSE;
			MaintenanceStation.Command.Execute := FALSE;
			ThroughputStation.Command.Execute := FALSE;
			
			IF gTrakAsm.Status.Disabled THEN
				AsmPowerOff.Execute := FALSE;
				Step := POWERED_OFF;
			END_IF
			
		WAIT_POWER_OFF:
			
		POWERED_OFF:
			IF gTrakAsm.Command.Power AND gTrakAsm.Status.Disabled THEN
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
			IF NOT gTrakAsm.Command.Power THEN
				AsmPowerOff.Execute := TRUE;
				Step := POWER_OFF;
			ELSIF gTrakAsm.Command.StartMovement AND gTrakAsm.ShuttleCnt > 0 THEN
				gTrakAsm.Command.StartMovement := FALSE;
				Step := START_MOVEMENT;
			END_IF
			
		START_MOVEMENT:
			FOR CurrentShuttleNumber := 1 TO gTrakAsm.ShuttleCnt BY 1 DO
				ShuttleList[CurrentShuttleNumber].RoutedMoveVel.Axis := ADR(ShuttleList[CurrentShuttleNumber].ShuttleReference);
				ShuttleList[CurrentShuttleNumber].RoutedMoveVel.Sector := ADR(MainLoop);
				ShuttleList[CurrentShuttleNumber].RoutedMoveVel.Velocity := gTrakAsm.Parameter.Velocity;
				ShuttleList[CurrentShuttleNumber].RoutedMoveVel.RouteVelocity := gTrakAsm.Parameter.Velocity;
				ShuttleList[CurrentShuttleNumber].RoutedMoveVel.Acceleration := gTrakAsm.Parameter.Acceleration;
				ShuttleList[CurrentShuttleNumber].RoutedMoveVel.Deceleration := gTrakAsm.Parameter.Deceleration;
				ShuttleList[CurrentShuttleNumber].RoutedMoveVel.Jerk := 0.0;
//				ShuttleList[CurrentShuttleNumber].RoutedMoveVel.Direction := mcDIR_POSITIVE;
				ShuttleList[CurrentShuttleNumber].RoutedMoveVel.BufferMode := mcABORTING;
				ShuttleList[CurrentShuttleNumber].RoutedMoveVel.Execute := TRUE;
			END_FOR
			
			Step := WAIT_START_MOVEMENT;
			
		WAIT_START_MOVEMENT:
//			FOR CurrentShuttleNumber := 1 TO gTrakAsm.ShuttleCnt BY 1 DO
//				ShuttleList[CurrentShuttleNumber].ElasticMoveVel.Execute := FALSE;
//			END_FOR
			
			Step := MOVING;
			
		MOVING:
			ActBufferBarrier;
			ActWorkStation1;
			ActWorkStation2;
			ActWorkStation3;
			ActWorkStation4;
			
			IF gTrakAsm.Command.StopMovement THEN
				gTrakAsm.Command.StopMovement := FALSE;
				Step := STOPPING;
			END_IF
			
		STOPPING:
			FOR CurrentShuttleNumber := 1 TO MAX_SHUTTLE_CNT BY 1 DO
				ShuttleList[CurrentShuttleNumber].RoutedMoveVel.Execute := FALSE;
			END_FOR
			AsmStop.Execute := TRUE;
			
			IF AsmStop.Done THEN
				AsmStop.Execute := FALSE;
				Step := READY;
			END_IF
			
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