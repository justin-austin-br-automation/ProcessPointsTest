ACTION ActWorkStation2:
	
	CASE WorkStation2.Step OF
		WAIT:
			WorkStation2.ElasticMoveAbs.Execute := FALSE;
			
			IF WorkStation2.TrgEnable.EventCount > 0 THEN
				WorkStation2.TrgGetInfo.Execute := TRUE;
				WorkStation2.Step := DIRECTION_CHECK;
			END_IF
			
		DIRECTION_CHECK:
			IF WorkStation2.TrgGetInfo.TrgPointInfo.Event = mcACPTRAK_TP_PASSED_POSITIVE THEN
				WorkStation2.Shuttle := WorkStation2.TrgGetInfo.TrgPointInfo.Axis;
				
				FOR i := 1 TO gMAX_SHUTTLE_CNT DO
					IF WorkStation2.Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
						gShuttleList[i].State := AT_STATION_2;
					END_IF
				END_FOR
				
				WorkStation2.TrgGetInfo.Execute := FALSE;
				WorkStation2.Step := PROCESS;
			ELSE
				WorkStation2.TrgGetInfo.Execute := FALSE;
				WorkStation2.Step := WAIT;
			END_IF
			
		PROCESS:
			WorkStation2.Timer.PT := T#2s;
			WorkStation2.Timer.IN := TRUE;
			
			IF WorkStation2.Timer.Q AND WorkStation3.ReadyForShuttle THEN
				WorkStation2.Timer.IN := FALSE;
				WorkStation2.Step := SEND_SHUTTLE;
			END_IF
			
		SEND_SHUTTLE:
			WorkStation2.ElasticMoveAbs.Axis := ADR(WorkStation2.Shuttle);
			WorkStation2.ElasticMoveAbs.Position := 1.485;
			WorkStation2.ElasticMoveAbs.Velocity := gTrakAsm.Parameter.Velocity;
			WorkStation2.ElasticMoveAbs.Acceleration := gTrakAsm.Parameter.Acceleration;
			WorkStation2.ElasticMoveAbs.Deceleration := gTrakAsm.Parameter.Deceleration;
			WorkStation2.ElasticMoveAbs.Jerk := 0.0;
			WorkStation2.ElasticMoveAbs.BufferMode := mcABORTING;
			WorkStation2.ElasticMoveAbs.Execute := TRUE;
			
			FOR i := 1 TO gMAX_SHUTTLE_CNT DO
				IF WorkStation2.Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
					gShuttleList[i].State := RTE_TO_STATION_3;
				END_IF
			END_FOR
			
			gStation2ReadyForShuttle := TRUE;
			WorkStation3.ReadyForShuttle := FALSE;
			WorkStation2.Step := WAIT;
		
	END_CASE
	
	WorkStation2.ElasticMoveAbs();
	WorkStation2.TrgEnable();
	WorkStation2.TrgGetInfo();
	WorkStation2.Timer();
END_ACTION