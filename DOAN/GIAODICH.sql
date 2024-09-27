-- TĂNG MÃ GIAO DỊCH
CREATE PROCEDURE sp_SelfIncreasingID_CT
    @NewMAGDCT VARCHAR(10) OUTPUT
AS
BEGIN
    DECLARE @MaxMAGDCT VARCHAR(10)
    SET @MaxMAGDCT = (
        SELECT MAX(MAGD)
        FROM (
            SELECT MAX(MAGD) AS MAGD FROM GD_CHUYENNHAN
            UNION
            SELECT MAX(MAGD) AS MAGD FROM QLNH_LINK.QLNGANHANG.DBO.GD_CHUYENNHAN
        ) AS CombinedMaxMAGDCT
    )

    IF @MaxMAGDCT IS NULL
        SET @NewMAGDCT = 'GD10001'
    ELSE
        SET @NewMAGDCT = 'GD1' + RIGHT('0000' + CAST(SUBSTRING(@MaxMAGDCT, 4, 4) + 1 AS VARCHAR(4)), 4)
END
GO
--------------------------------------------
CREATE PROCEDURE sp_SelfIncreasingID_GR
    @NewMAGDGR VARCHAR(10) OUTPUT
AS
BEGIN
    DECLARE @MaxMAGDGR VARCHAR(10)
    SET @MaxMAGDGR = (
        SELECT MAX(MAGD)
        FROM (
            SELECT MAX(MAGD) AS MAGD FROM GD_GOIRUT
            UNION
            SELECT MAX(MAGD) AS MAGD FROM QLNH_LINK.QLNGANHANG.DBO.GD_GOIRUT
        ) AS CombinedMaxMAGDCT
    )

    IF @MaxMAGDGR IS NULL
        SET @NewMAGDGR = 'GD20001'
    ELSE
        SET @NewMAGDGR = 'GD2' + RIGHT('0000' + CAST(SUBSTRING(@MaxMAGDGR, 4, 4) + 1 AS VARCHAR(4)), 4)
END
GO

--CHUYỂN TIỀN
ALTER PROC sp_GiaoDichCT
	@stkgui VARCHAR(10),
	@stknhan VARCHAR(10),
	@sotien MONEY,
	@manv VARCHAR(10)
AS
BEGIN
	DECLARE @magd VARCHAR(10), @sodutkg MONEY, @makhgui VARCHAR(10), @makhnhan VARCHAR(10), @trangthaigui INT, @trangthainhan INT
	EXEC sp_SelfIncreasingID_CT @magd OUTPUT

	SELECT @sodutkg = SODU FROM TKNH WHERE SOTK = @stkgui

	SELECT @makhgui = KH.MAKH, @trangthaigui = TNH.TRANGTHAI
	FROM KHACHHANG KH
	JOIN TKNH TNH ON KH.SDT = @stkgui AND TNH.MAKH = KH.MAKH

	SELECT @makhnhan = KH.MAKH, @trangthainhan = TNH.TRANGTHAI
	FROM KHACHHANG KH
	JOIN TKNH TNH ON KH.SDT = @stknhan AND TNH.MAKH = KH.MAKH
	--
	IF (@trangthaigui = 0 OR NOT EXISTS(SELECT 1 FROM TKNH WHERE SOTK = @stkgui)) BEGIN
		IF (@trangthainhan = 0 OR NOT EXISTS(SELECT 1 FROM TKNH WHERE SOTK = @stknhan)) BEGIN
			PRINT (N'Cả tài khoản gửi và tài khoản nhận không tồn tại')
			RETURN
		END
		ELSE BEGIN
			PRINT (N'Tài khoản gửi không tồn tại')
			RETURN
		END
	END
	ELSE IF (@trangthainhan = 0 OR NOT EXISTS(SELECT 1 FROM TKNH WHERE SOTK = @stknhan)) BEGIN
		PRINT (N'Tài khoản nhận không tồn tại')
		RETURN
	END
	ELSE BEGIN
		IF @sotien < 10000 BEGIN
			PRINT (N'Số tiền chuyển phải lớn hơn 10,000')
			RETURN
		END	
		IF (@sodutkg < @sotien) BEGIN
			PRINT (N'Tài khoản không đủ để thực hiện giao dịch')
			RETURN
		END
        -- Cập nhật số dư tài khoản gửi
        UPDATE TKNH
        SET SODU = SODU - @sotien
        WHERE SOTK = @stkgui;

        -- Cập nhật số dư tài khoản nhận
        UPDATE TKNH
        SET SODU = SODU + @sotien
        WHERE SOTK = @stknhan;

        -- Lưu thông tin giao dịch
		INSERT INTO GD_CHUYENNHAN (MAGD, SOTK_GUI, SOTK_NHAN, SOTIEN, NGAYGD, MANV)
		VALUES (@magd, @stkgui, @stknhan, @sotien, GETDATE(), @manv)
	END
END
------------------------
select * from NHANVIEN
select * from QLNH_LINK.QLNGANHANG.DBO.KHACHHANG
select * from TKNH
select * from GD_CHUYENNHAN
select * from QLNH_LINK.QLNGANHANG.DBO.GD_CHUYENNHAN
exec sp_GiaoDichCT 
	@stkgui = '0924681235',
	@stknhan = '0789123456',
	@sotien = 1150000,
	@manv = 'NV003'
GO

-- GỞI TIỀN
ALTER PROCEDURE sp_GiaoDichGT
    @stk VARCHAR(10),
    @sotien MONEY,
    @manv VARCHAR(10)
AS
BEGIN
	DECLARE @magd VARCHAR(10), @makh VARCHAR(10), @trangthai INT
	EXEC sp_SelfIncreasingID_GR @magd OUTPUT

	SELECT @makh = KH.MAKH, @trangthai = TNH.TRANGTHAI
	FROM KHACHHANG KH
	JOIN TKNH TNH ON KH.SDT = @stk AND TNH.MAKH = KH.MAKH

	IF (@trangthai = 0 OR NOT EXISTS(SELECT 1 FROM TKNH WHERE SOTK = @stk)) BEGIN
		PRINT (N'Tài khoản không tồn tại')
	END
	ELSE BEGIN
        UPDATE TKNH
        SET SODU = SODU + @sotien
        WHERE SOTK = @stk;

        INSERT INTO GD_GOIRUT (MAGD, SOTK, LOAIGD, SOTIEN, NGAYGD, MANV)
        VALUES (@magd, @stk, 'GT', @sotien, GETDATE(), @manv);
	END
END;
--------------------------
EXEC sp_GiaoDichGT @stk ='0924681235', @sotien = 50000, @manv = 'NV002'
select * from GD_GOIRUT
select * from TKNH
GO


-- RÚT TIỀN
ALTER PROC sp_GiaoDichRT
	@stk VARCHAR(10),
	@sotien MONEY,
	@manv VARCHAR(10)
AS
BEGIN
	DECLARE @magd VARCHAR(10), @sodutk MONEY, @makh VARCHAR(10), @trangthai INT
	EXEC sp_SelfIncreasingID_GR @magd OUTPUT

	SELECT @makh = KH.MAKH, @trangthai = TNH.TRANGTHAI
	FROM KHACHHANG KH
	JOIN TKNH TNH ON KH.SDT = @stk AND TNH.MAKH = KH.MAKH

	SELECT @sodutk = SODU FROM TKNH WHERE SOTK = @stk
	--
	IF (@trangthai = 0 OR NOT EXISTS(SELECT 1 FROM TKNH WHERE SOTK = @stk)) BEGIN
		PRINT (N'Tài khoản không tồn tại')
	END
	ELSE BEGIN
		IF (@sotien > @sodutk) BEGIN
			PRINT (N'Tài khoản không đủ để thực hiện giao dịch')
			RETURN 
		END
		ELSE BEGIN
			IF (@sotien = 0) BEGIN 
				PRINT (N'Vui lòng nhập số tiền cần rút')
				RETURN
			END
		END
		--
		UPDATE TKNH
		SET SODU = SODU - @sotien
		WHERE SOTK = @stk;

		INSERT INTO GD_GOIRUT (MAGD, SOTK, LOAIGD, SOTIEN, NGAYGD, MANV)
		VALUES (@magd, @stk, 'RT', @sotien, GETDATE(), @manv);
	END
END
-------------------
exec sp_GiaoDichRT @stk ='0924681235', @sotien = 10000, @manv = 'NV002'
select * from TKNH
select * from GD_GOIRUT
