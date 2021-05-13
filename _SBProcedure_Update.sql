drop PROCEDURE _SBProcedure_Update;

DELIMITER $$
CREATE PROCEDURE _SBProcedure_Update
	(
		 InData_OperateFlag			CHAR(2)			-- 작업표시
		,InData_CompanySeq			INT				-- 법인내부코드
        ,InData_ProcedureName		VARCHAR(200)	-- (기존)프로시져명
		,InData_ChgProcedureName	VARCHAR(200)    -- (변경)프로시져명
		,InData_ProcedureRemark		VARCHAR(200)	-- 프로시져설명
		,InData_ProcedureType		INT				-- 프로시져타입
		,InData_Remark				VARCHAR(500)	-- 작업내용
		,Login_UserSeq				INT				-- 현재 로그인 중인 유저
    )
BEGIN

	-- 변수선언
	DECLARE Var_ProcedureSeq INT;
    
	SET Var_ProcedureSeq = (SELECT ProcedureSeq FROM _TCBaseProcedure AS A WHERE A.CompanySeq = InData_CompanySeq AND A.ProcedureName = InData_ProcedureName);                

                
    -- ---------------------------------------------------------------------------------------------------
    -- Update --
	IF( InData_OperateFlag = 'U' ) THEN     
               
			UPDATE _TCBaseProcedure AS A
			   SET  A.ProcedureName 		= InData_ChgProcedureName
				   ,A.ProcedureRemark 		= InData_ProcedureRemark
				   ,A.ProcedureType 		= InData_ProcedureType
				   ,A.Remark 				= InData_Remark
			WHERE A.CompanySeq				= InData_CompanySeq 
			  AND A.ProcedureSeq			= Var_ProcedureSeq;  
                     
              SELECT '저장되었습니다.' AS Result; 
                     
	ELSE
			  SELECT '저장이 완료되지 않았습니다.' AS Result;
	END IF;	


END $$
DELIMITER ;