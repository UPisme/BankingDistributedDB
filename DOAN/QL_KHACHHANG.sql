﻿-- DANH SÁCH KHÁCH HÀNG --
CREATE PROC sp_CustomersList
AS
BEGIN
	SELECT * FROM KHACHHANG
END
GO

-- TÌM KIẾM KHÁCH HÀNG THEO CCCD --
CREATE PROC sp_CustomerSearch
	@CCCD VARCHAR(12)
AS
BEGIN
	SELECT * FROM KHACHHANG WHERE CCCD = @CCCD
END
GO


-- TẠO MÃ KHÁCH HÀNG TỰ TĂNG --
CREATE PROCEDURE sp_SelfIncreasingID
    @NewMAKH VARCHAR(10) OUTPUT
AS
BEGIN
    DECLARE @MaxMAKH VARCHAR(10)
    SET @MaxMAKH = (
        SELECT MAX(MAKH)
        FROM (
            SELECT MAX(MAKH) AS MAKH FROM KHACHHANG
            UNION
            SELECT MAX(MAKH) AS MAKH FROM QLNH_LINK.QLNGANHANG.dbo.KHACHHANG
        ) AS CombinedMaxMAKH
    )

    IF @MaxMAKH IS NULL
        SET @NewMAKH = 'KH0001'
    ELSE
        SET @NewMAKH = 'KH' + RIGHT('0000' + CAST(SUBSTRING(@MaxMAKH, 3, 4) + 1 AS VARCHAR(4)), 4)
END
GO


-- THÊM KHÁCH HÀNG MỚI --
ALTER PROC sp_AddCustomer
	@HO NVARCHAR(40),
	@TEN NVARCHAR(10),
	@NGSINH DATE,
	@PHAI INT,
	@CCCD VARCHAR(12),
	@SDT VARCHAR(10),
	@DIACHI NVARCHAR(100)
AS
BEGIN
	DECLARE @MAKH VARCHAR(10)
	EXEC sp_SelfIncreasingID @MAKH OUTPUT

	DECLARE @MACN VARCHAR(10)
	DECLARE @ServerName VARCHAR(100) = (SELECT @@SERVERNAME)
	IF @ServerName = 'DESKTOP-S2CBG3S\MSSQLSERVER01'
	BEGIN
		SET @MACN = 'CN01'
	END
	ELSE IF @ServerName = 'DESKTOP-S2CBG3S\MSSQLSERVER02'
	BEGIN
		SET @MACN = 'CN02'
	END

	IF(EXISTS(SELECT 1 FROM KHACHHANG WHERE CCCD = @CCCD))
	BEGIN
		PRINT N'Người này đã là khách hàng ở chi nhánh 1!'
	END
	ELSE IF(EXISTS(SELECT 1 FROM QLNH_LINK.QLNGANHANG.dbo.KHACHHANG WHERE CCCD = @CCCD))
	BEGIN
		PRINT N'Người này đã là khách hàng ở chi nhánh 2!'
	END
	ELSE IF(EXISTS(SELECT 1 FROM KHACHHANG WHERE SDT = @SDT) OR EXISTS(SELECT 1 FROM QLNH_LINK.QLNGANHANG.dbo.KHACHHANG WHERE SDT = @SDT))
	BEGIN
		PRINT N'Số điện thoại này đã được sử dụng!'
	END
	ELSE
	BEGIN
		INSERT INTO KHACHHANG (MAKH, HO, TEN, NGSINH, PHAI, CCCD, SDT, DIACHI, MACN)
		VALUES (@MAKH, @HO, @TEN, @NGSINH, @PHAI, @CCCD, @SDT, @DIACHI, @MACN)
	END
END
GO


-- XÓA KHÁCH HÀNG --
CREATE PROC sp_DeleteCustomer
	@CCCD VARCHAR(12)
AS
BEGIN
	DELETE FROM KHACHHANG WHERE CCCD = @CCCD
END