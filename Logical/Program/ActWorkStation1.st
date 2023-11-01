ACTION ActWorkStation1:
	
	CASE WorkStation1.Step OF
		WAIT:
			WorkStation1.ElasticMoveAbs.Execute := FALSE;
			
			IF WorkStation1.TrgEnable.EventCount <> 0 THEN
				WorkStation1.ReadyForShuttle := FALSE;
				WorkStation1.TrgGetInfo.Execute := TRUE;
				WorkStation1.Step := DIRECTION_CHECK;
			END_IF
			
		DIRECTION_CHECK:
			IF WorkStation1.TrgGetInfo.TrgPointInfo.Event = mcACPTRAK_TP_PASSED_POSITIVE THEN
				WorkStation1.Shuttle := WorkStation1.TrgGetInfo.TrgPointInfo.Axis;
				
				FOR i := 1 TO gMAX_SHUTTLE_CNT BY 1 DO
					IF BufferBarrier.Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
						gShuttleList[i].State := AT_STATION_1;
					END_IF
				END_FOR
				
				WorkStation1.TrgGetInfo.Execute := FALSE;
				WorkStation1.Step := PROCESS;
			ELSE
				WorkStation1.TrgGetInfo.Execute := FALSE;
				WorkStation1.Step := WAIT;
			END_IF
			
		PROCESS:
			WorkStation1.Timer.PT := T#2s;
			WorkStation1.Timer.IN := TRUE;
			
			IF WorkStation1.Timer.Q  AND WorkStation2.ReadyForShuttle THEN
				WorkStation1.Timer.IN := FALSE;
				WorkStation1.Step := SEND_SHUTTLE;
			END_IF
			
		SEND_SHUTTLE:
			WorkStation1.ElasticMoveAbs.Axis := ADR(WorkStation1.Shuttle);
			WorkStation1.ElasticMoveAbs.Position := 0.99;
			WorkStation1.ElasticMoveAbs.Velocity := gTrakAsm.Parameter.Velocity;
			WorkStation1.ElasticMoveAbs.Acceleration := gTrakAsm.Parameter.Acceleration;
			WorkStation1.ElasticMoveAbs.Deceleration := gTrakAsm.Parameter.Deceleration;
			WorkStation1.ElasticMoveAbs.Jerk := 0.0;
			WorkStation1.ElasticMoveAbs.BufferMode := mcABORTING;
			WorkStation1.ElasticMoveAbs.Execute := TRUE;
			
			FOR i := 1 TO gMAX_SHUTTLE_CNT BY 1 DO
				IF BufferBarrier.Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
					gShuttleList[i].State := RTE_TO_STATION_2;
				END_IF
			END_FOR
			
			WorkStation1.ReadyForShuttle := TRUE;
			WorkStation2.ReadyForShuttle := FALSE;
			WorkStation1.Step := WAIT;
		
	END_CASE
	
	WorkStation1.ElasticMoveAbs();
	WorkStation1.TrgEnable();
	WorkStation1.TrgGetInfo();
	WorkStation1.Timer();
END_ACTION