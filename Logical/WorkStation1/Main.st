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
				Shuttle := WorkStation1.TrgGetInfo.TrgPointInfo.Axis;
				
				FOR i := 1 TO gMAX_SHUTTLE_CNT DO
					IF Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
						gShuttleList[i].State := AT_STATION_1;
					END_IF
				END_FOR
				
				TrgGetInfo.Execute := FALSE;
				Step := PROCESS;
			ELSE
				TrgGetInfo.Execute := FALSE;
				Step := WAIT;
			END_IF
			
		PROCESS:
			Timer.PT := T#2s;
			Timer.IN := TRUE;
			
			IF Timer.Q  AND WorkStation2.ReadyForShuttle THEN
				Timer.IN := FALSE;
				Step := SEND_SHUTTLE;
			END_IF
			
		SEND_SHUTTLE:
			ElasticMoveAbs.Axis := ADR(WorkStation1.Shuttle);
			ElasticMoveAbs.Position := 0.99;
			ElasticMoveAbs.Velocity := gTrakAsm.Parameter.Velocity;
			ElasticMoveAbs.Acceleration := gTrakAsm.Parameter.Acceleration;
			ElasticMoveAbs.Deceleration := gTrakAsm.Parameter.Deceleration;
			ElasticMoveAbs.Jerk := 0.0;
			ElasticMoveAbs.BufferMode := mcABORTING;
			ElasticMoveAbs.Execute := TRUE;
			
			FOR i := 1 TO gMAX_SHUTTLE_CNT DO
				IF Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
					gShuttleList[i].State := RTE_TO_STATION_2;
				END_IF
			END_FOR
			
			gStation1ReadyForShuttle := TRUE;
			WorkStation2.ReadyForShuttle := FALSE;
			Step := WAIT;
		
	END_CASE
	
	gStation1EventCount := TrgEnable.EventCount;
	
	WorkStation1.ElasticMoveAbs();
	WorkStation1.TrgEnable();
	WorkStation1.TrgGetInfo();
	WorkStation1.Timer();
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	
END_PROGRAM