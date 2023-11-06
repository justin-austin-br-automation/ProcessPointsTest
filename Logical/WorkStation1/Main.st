PROGRAM _INIT
	TrgGetInfo.ProcessPoint := ADR(PPStation1);
	TrgEnable.ProcessPoint := ADR(PPStation1);
	TrgEnable.Enable := TRUE;
	
	TrgGetInfo();
	TrgEnable();
END_PROGRAM

PROGRAM _CYCLIC
	CASE Step OF
		WAIT:
			ElasticMoveAbs.Execute := FALSE;
			
			IF TrgEnable.EventCount > 0 THEN
				gStation1ReadyForShuttle := FALSE;
				TrgGetInfo.Execute := TRUE;
				Step := DIRECTION_CHECK;
			END_IF
			
		DIRECTION_CHECK:
			IF TrgGetInfo.TrgPointInfo.Event = mcACPTRAK_TP_PASSED_POSITIVE THEN
				Shuttle := TrgGetInfo.TrgPointInfo.Axis;
				
				FOR i := 1 TO gMAX_SHUTTLE_CNT DO
					IF Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
						gShuttleList[i].State := AT_STATION_1;
						ShuttleIndex := i;
					END_IF
				END_FOR
				
				TrgGetInfo.Execute := FALSE;
				Step := PROCESS;
			ELSE
				TrgGetInfo.Execute := FALSE;
				Step := WAIT;
			END_IF
			
		PROCESS:
			Timer.PT := gPROCESS_TIMER_LENGTH;
			Timer.IN := TRUE;
			
			IF Timer.Q  AND gStation2ReadyForShuttle THEN
				Timer.IN := FALSE;
				Step := SEND_SHUTTLE;
			END_IF
			
		SEND_SHUTTLE:
			ElasticMoveAbs.Axis := ADR(Shuttle);
			ElasticMoveAbs.Position := gPROCESS_POINT_LOCATIONS.WORK_STATION2;
			ElasticMoveAbs.Velocity := gTrakAsm.Parameter.Velocity;
			ElasticMoveAbs.Acceleration := gTrakAsm.Parameter.Acceleration;
			ElasticMoveAbs.Deceleration := gTrakAsm.Parameter.Deceleration;
			ElasticMoveAbs.Jerk := 0.0;
			ElasticMoveAbs.BufferMode := mcABORTING;
			ElasticMoveAbs.Execute := TRUE;
			
			gShuttleList[ShuttleIndex].State := RTE_TO_STATION_2;
			
			gStation1ReadyForShuttle := TRUE;
			gStation2ReadyForShuttle := FALSE;
			Step := WAIT;
		
	END_CASE
	
	gStation1EventCount := TrgEnable.EventCount;
	
	ElasticMoveAbs();
	TrgEnable();
	TrgGetInfo();
	Timer();
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	
END_PROGRAM