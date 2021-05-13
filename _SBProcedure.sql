drop PROCEDURE _SBProcedure;

DELIMITER $$
CREATE PROCEDURE _SBProcedure
	(
		 InData_OperateFlag			CHAR(2)			-- 작업표시
		,InData_CompanySeq			INT				-- 법인내부코드        
        ,InData_ProcedureName		VARCHAR(200)	-- (기존)프로시져명
		,InData_ChgProcedureName	VARCHAR(200)    -- (변경)프로시져명
		,InData_ProcedureRemark		VARCHAR(200)	-- 프로시져설명
		,InData_ProcedureType		INT				-- 프로시져타입
		,InData_Remark				VARCHAR(500)	-- 작업내용
		,Login_UserSeq		INT				-- 현재 로그인 중인 유저
    )
BEGIN
    
    DECLARE State INT;
    
    -- ---------------------------------------------------------------------------------------------------
    -- Check --
	call _SBProcedure_Check
		(
			 InData_OperateFlag
			,InData_CompanySeq
			,InData_ProcedureName	
			,InData_ChgProcedureName
            ,InData_ProcedureRemark
            ,InData_ProcedureType
            ,InData_Remark
            ,Login_UserSeq
           ,@Error_Check
		);
    

	IF( @Error_Check = (SELECT 9999) ) THEN
		
        SET State = 9999; -- Error 발생
        
	ELSE

	    SET State = 1111; -- 정상작동
        
		-- ---------------------------------------------------------------------------------------------------
		-- Save --
		IF( (InData_OperateFlag = 'S' OR InData_OperateFlag = 'D') AND STATE = 1111 ) THEN
			call _SBProcedure_Save
				(
					InData_OperateFlag
					,InData_CompanySeq
					,InData_ProcedureName	
					,InData_ChgProcedureName
					,InData_ProcedureRemark
					,InData_ProcedureType
					,InData_Remark
					,Login_UserSeq
				);
		END IF;	
    
		-- ---------------------------------------------------------------------------------------------------
		-- Update --
		IF( InData_OperateFlag = 'U' AND STATE = 1111 ) THEN
			call _SBProcedure_Update
				(
					InData_OperateFlag
					,InData_CompanySeq
					,InData_ProcedureName	
					,InData_ChgProcedureName
					,InData_ProcedureRemark
					,InData_ProcedureType
					,InData_Remark
					,Login_UserSeq
				);		
		END IF;	    

	END IF;
END $$
DELIMITER ;