drop PROCEDURE _SBProcedure_Save;

DELIMITER $$
CREATE PROCEDURE _SBProcedure_Save
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
	DECLARE Var_IsCheckOut				CHAR(1);
	DECLARE Var_CheckOutStartDate		VARCHAR(100);
	DECLARE Var_CheckOutEndDate  		VARCHAR(100);
    DECLARE Var_ProcedureSeq 			INT;      
    DECLARE Var_ProcedureSerl 			INT;    		-- _TCBaseProcedureHist 테이블의 Serl순번 
    DECLARE Var_ProcedureHistRemark  	VARCHAR(100);   -- _TCBaseProcedureHist 테이블의 Remark
    
	SET Var_IsCheckOut			= (SELECT 1); 													-- Insert할 경우 체크아웃 '1' default 설정
    SET Var_ProcedureSerl		= (SELECT 1); 													-- Insert할 경우 ProcedureSerl 순번 '1' default 설정
	SET Var_CheckOutStartDate	= (SELECT DATE_FORMAT(NOW(), "%Y-%m-%d %H:%i:%s") AS GetDate);	-- Insert하는 기준의 일시부터 default 설정
    SET Var_CheckOutEndDate 	= (SELECT '9999-12-31 00:00:00');								-- Insert할 경우 기본시간 '9999-12-31 00:00:00' default 설정
    

    -- ---------------------------------------------------------------------------------------------------
    -- Insert --
	IF( InData_OperateFlag = 'S' ) THEN
		INSERT INTO _TCBaseProcedure 
		( 	 
			  CompanySeq				-- 법인내부코드
			, ProcedureName				-- 프로시져명
			, ProcedureRemark			-- 프로시져설명
			, ProcedureType				-- 프로시져타입
			, IsCheckOut				-- 체크아웃여부
			, Remark					-- 작업내용
			, CheckOutUserSeq			-- 체크아웃작업자
			, CheckOutStartDate			-- 체크아웃시작일시
            , CheckOutEndDate			-- 체크아웃종료일시
        )
		VALUES
		(
			  InData_CompanySeq
			, InData_ProcedureName
			, InData_ProcedureRemark
			, InData_ProcedureType
			, Var_IsCheckOut
			, InData_Remark
			, Login_UserSeq
			, Var_CheckOutStartDate
            , Var_CheckOutEndDate
		);
        
		SET Var_ProcedureSeq = (SELECT A.ProcedureSeq FROM _TCBaseProcedure AS A WHERE A.CompanySeq = InData_CompanySeq AND ProcedureName = InData_ProcedureName);    
        SET Var_ProcedureHistRemark = '신규Procedure생성'; -- 처음 Procedure 생성할 경우 Remark Default설정 
        
		-- 저장할 경우 프로시져기록관리(_TCBaseProcedureHist) 테이블에 자동 데이터 생성
		INSERT INTO _TCBaseProcedureHist 
		( 	 
			  CompanySeq				-- 법인내부코드
			, ProcedureSeq				-- 프로시져내부코드
            , ProcedureSerl				-- 프로시져내부순번
			, IsCheckOut				-- 체크아웃여부
			, Remark					-- 작업내용
			, CheckOutUserSeq			-- 체크아웃작업자
			, CheckOutStartDate			-- 체크아웃시작일시
            , CheckOutEndDate			-- 체크아웃종료일시
        )
		VALUES
		(
			  InData_CompanySeq
			, Var_ProcedureSeq
            , Var_ProcedureSerl
			, Var_IsCheckOut
			, Var_ProcedureHistRemark
			, Login_UserSeq
			, Var_CheckOutStartDate
            , Var_CheckOutEndDate
		);
        
        SELECT '저장이 완료되었습니다' AS Result;
        
        
	-- ---------------------------------------------------------------------------------------------------        
    -- Delete --
	ELSEIF ( InData_OperateFlag = 'D' ) THEN  
    
		SET Var_ProcedureSeq = (SELECT A.ProcedureSeq FROM _TCBaseProcedure AS A WHERE A.CompanySeq = InData_CompanySeq AND ProcedureName = InData_ProcedureName);  
        
		DELETE FROM _TCBaseProcedure 		WHERE CompanySeq = InData_CompanySeq AND ProcedureSeq = Var_ProcedureSeq;
		DELETE FROM _TCBaseProcedureHist 	WHERE CompanySeq = InData_CompanySeq AND ProcedureSeq = Var_ProcedureSeq;

        SELECT '삭제되었습니다.' AS Result; 
	END IF;	


END $$
DELIMITER ;