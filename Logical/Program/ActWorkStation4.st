ACTION ActWorkStation4:
	
	CASE WorkStation4.Step OF
		WAIT:
			WorkStation4.RoutedMoveVel.Execute := FALSE;
			
			IF WorkStation4.TrgEnable.EventCount <> 0 THEN
				WorkStation4.TrgGetInfo.Execute := TRUE;
				WorkStation4.Step := DIRECTION_CHECK;
			END_IF
			
		DIRECTION_CHECK:
			IF WorkStation4.TrgGetInfo.TrgPointInfo.Event = mcACPTRAK_TP_PASSED_POSITIVE THEN
				WorkStation4.Shuttle := WorkStation4.TrgGetInfo.TrgPointInfo.Axis;
				WorkStation4.TrgGetInfo.Execute := FALSE;
				WorkStation4.Step := PROCESS;
			ELSE
				WorkStation4.TrgGetInfo.Execute := FALSE;
				WorkStation4.Step := WAIT;
			END_IF
			
		PROCESS:
			WorkStation4.Timer.PT := T#2s;
			WorkStation4.Timer.IN := TRUE;
			
			IF WorkStation4.Timer.Q THEN
				WorkStation4.Timer.IN := FALSE;
				WorkStation4.Step := SEND_SHUTTLE;
			END_IF
			
		SEND_SHUTTLE:
			WorkStation4.ElasticMoveAbs.Axis := ADR(WorkStation4.Shuttle);
			WorkStation4.RoutedMoveVel.Sector := ADR(MainLoop);
			WorkStation4.RoutedMoveVel.Velocity := gTrakAsm.Parameter.Velocity;
			WorkStation4.RoutedMoveVel.RouteVelocity := gTrakAsm.Parameter.Velocity;
			WorkStation4.RoutedMoveVel.Acceleration := gTrakAsm.Parameter.Acceleration;
			WorkStation4.RoutedMoveVel.Deceleration := gTrakAsm.Parameter.Deceleration;
			WorkStation4.RoutedMoveVel.Jerk := 0.0;
			WorkStation4.RoutedMoveVel.BufferMode := mcABORTING;
			WorkStation4.RoutedMoveVel.Execute := TRUE;
			
			WorkStation4.Step := WAIT;
		
	END_CASE
	
	WorkStation4.TrgEnable();
	WorkStation4.TrgGetInfo();
	WorkStation4.RoutedMoveVel();
	WorkStation4.Timer();
END_ACTION