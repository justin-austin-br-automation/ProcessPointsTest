ACTION ActWorkStation3:
	
	CASE WorkStation3.Step OF
		WAIT:
			WorkStation3.ElasticMoveAbs.Execute := FALSE;
			
			IF WorkStation3.TrgEnable.EventCount > 0 THEN
				WorkStation3.TrgGetInfo.Execute := TRUE;
				WorkStation3.Step := DIRECTION_CHECK;
			END_IF
			
		DIRECTION_CHECK:
			IF WorkStation3.TrgGetInfo.TrgPointInfo.Event = mcACPTRAK_TP_PASSED_POSITIVE THEN
				WorkStation3.Shuttle := WorkStation3.TrgGetInfo.TrgPointInfo.Axis;
				
				FOR i := 1 TO gMAX_SHUTTLE_CNT DO
					IF WorkStation3.Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
						gShuttleList[i].State := AT_STATION_3;
					END_IF
				END_FOR
				
				WorkStation3.TrgGetInfo.Execute := FALSE;
				WorkStation3.Step := PROCESS;
			ELSE
				WorkStation3.TrgGetInfo.Execute := FALSE;
				WorkStation3.Step := WAIT;
			END_IF
			
		PROCESS:
			WorkStation3.Timer.PT := T#2s;
			WorkStation3.Timer.IN := TRUE;
			
			IF WorkStation3.Timer.Q AND WorkStation4.ReadyForShuttle THEN
				WorkStation3.Timer.IN := FALSE;
				WorkStation3.Step := SEND_SHUTTLE;
			END_IF
			
		SEND_SHUTTLE:
			WorkStation3.ElasticMoveAbs.Axis := ADR(WorkStation3.Shuttle);
			WorkStation3.ElasticMoveAbs.Position := 1.98;
			WorkStation3.ElasticMoveAbs.Velocity := gTrakAsm.Parameter.Velocity;
			WorkStation3.ElasticMoveAbs.Acceleration := gTrakAsm.Parameter.Acceleration;
			WorkStation3.ElasticMoveAbs.Deceleration := gTrakAsm.Parameter.Deceleration;
			WorkStation3.ElasticMoveAbs.Jerk := 0.0;
			WorkStation3.ElasticMoveAbs.BufferMode := mcABORTING;
			WorkStation3.ElasticMoveAbs.Execute := TRUE;
			
			FOR i := 1 TO gMAX_SHUTTLE_CNT DO
				IF WorkStation3.Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
					gShuttleList[i].State := RTE_TO_STATION_4;
				END_IF
			END_FOR
			
			gStation3ReadyForShuttle := TRUE;
			WorkStation4.ReadyForShuttle := FALSE;
			WorkStation3.Step := WAIT;
		
	END_CASE
	
	WorkStation3.ElasticMoveAbs();
	WorkStation3.TrgEnable();
	WorkStation3.TrgGetInfo();
	WorkStation3.Timer();
END_ACTION