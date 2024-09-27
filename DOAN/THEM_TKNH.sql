﻿--KIỂM TRA KHÁCH HÀNG VÀ THÊM TKNH
CREATE PROC sp_KiemTraTKNH 
    @CCCD VARCHAR(12),
	@SOTK VARCHAR(10),
	@MATKHAU VARCHAR(20)
AS
BEGIN
	-- Lấy tên chi nhánh
	DECLARE @HOTEN NVARCHAR(50), @HOTENKH VARCHAR(50),@MAKH VARCHAR(10), @MACN VARCHAR(10)

	DECLARE @ServerName VARCHAR(100) = (SELECT @@SERVERNAME)
	IF @ServerName = 'DESKTOP-S2CBG3S\MSSQLSERVER01'
	BEGIN
		SET @MACN = 'CN01'
	END
	ELSE IF @ServerName = 'DESKTOP-S2CBG3S\MSSQLSERVER02'
	BEGIN
		SET @MACN = 'CN02'
	END

    -- Kiểm tra khách hàng trong chi nhánh hiện tại và lấy thông tin nếu tồn tại
    IF EXISTS (SELECT 1 FROM KHACHHANG WHERE CCCD = @CCCD)
    BEGIN
        SET @HOTEN = (SELECT HO + ' ' + TEN FROM KHACHHANG WHERE CCCD = @CCCD) 
		SELECT @MAKH = MAKH FROM KHACHHANG WHERE CCCD = @CCCD
		SET @HOTENKH = dbo.fuConvertToUnsign(N'' + @HOTEN + '')

		IF EXISTS (SELECT 1 FROM TKNH WHERE SOTK = @SOTK)
		BEGIN
	        RAISERROR(N'TÀI KHOẢN NÀY ĐÃ TỒN TẠI', 16, 1)
			RETURN;
		END

		ELSE 
		BEGIN
			INSERT INTO TKNH(SOTK,TENTK,MATKHAU,NGAYTAO,SODU,TRANGTHAI,MAKH,MACN) VALUES (@SOTK, @HOTENKH,@MATKHAU, GETDATE(), 0, 1, @MAKH, @MACN)
		END
    END

    -- Kiểm tra khách hàng trong chi nhánh khác và lấy thông tin nếu tồn tại
    ELSE IF EXISTS (SELECT 1 FROM QLNH_LINK.QLNGANHANG.DBO.KHACHHANG WHERE CCCD = @CCCD)
    BEGIN
        SET @HOTEN = (SELECT HO + ' ' + TEN FROM QLNH_LINK.QLNGANHANG.DBO.KHACHHANG WHERE CCCD = @CCCD) 
		SELECT @MAKH = MAKH FROM QLNH_LINK.QLNGANHANG.DBO.KHACHHANG WHERE CCCD = @CCCD
		SET @HOTENKH = dbo.fuConvertToUnsign(N'' + @HOTEN + '')

		IF EXISTS (SELECT 1 FROM TKNH WHERE SOTK = @SOTK)
		BEGIN
	        RAISERROR(N'TÀI KHOẢN NÀY ĐÃ TỒN TẠI', 16, 1)
			RETURN;
		END

		ELSE 
		BEGIN
			INSERT INTO TKNH(SOTK,TENTK,MATKHAU,NGAYTAO,SODU,TRANGTHAI,MAKH,MACN) VALUES (@SOTK, @HOTENKH,@MATKHAU, GETDATE(), 0, 1, @MAKH, @MACN)
		END

    END
    -- Khách hàng chưa tồn tại
    ELSE
    BEGIN
        PRINT N'KHÁCH HÀNG CHƯA TỒN TẠI'
		RETURN;
    END
END

EXEC sp_KiemTraTKNH '078789123456','0985713246','abcd'

--HÀM CHUYỂN ĐỔI TỪ CÓ DẤU THÀNH KHÔNG DẤU
GO
CREATE FUNCTION fuConvertToUnsign (@strInput NVARCHAR(100))
RETURNS NVARCHAR(4000)
AS
BEGIN 
	 IF @strInput IS NULL RETURN @strInput
	 IF @strInput = '' RETURN @strInput

	 DECLARE @RT NVARCHAR(4000)
	 DECLARE @SIGN_CHARS NCHAR(136)
	 DECLARE @UNSIGN_CHARS NCHAR (136)

	 SET @SIGN_CHARS = N'ăâđêôơưàảãạáằẳẵặắầẩẫậấèẻẽẹéềểễệếìỉĩịíòỏõọóồổỗộốờởỡợớùủũụúừửữựứỳỷỹỵýĂÂĐÊÔƠƯÀẢÃẠÁẰẲẴẶẮẦẨẪẬẤÈẺẼẸÉỀỂỄỆẾÌỈĨỊÍÒỎÕỌÓỒỔỖỘỐỜỞỠỢỚÙỦŨỤÚỪỬỮỰỨỲỶỸỴÝ'
	 +NCHAR(272)+ NCHAR(208)
	 SET @UNSIGN_CHARS=N'aadeoouaaaaaaaaaaaaaaaeeeeeeeeeeiiiiiooooooooooooooouuuuuuuuuuyyyyyAADEOOUAAAAAAAAAAAAAAAEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOUUUUUUUUUUYYYYY'
	 DECLARE @COUNTER int
	 DECLARE @COUNTER1 int
	 SET @COUNTER = 1
	 WHILE (@COUNTER <=LEN(@strInput))
	 BEGIN 
		SET @COUNTER1 = 1
		WHILE (@COUNTER1 <=LEN(@SIGN_CHARS)+1)
		BEGIN
			IF UNICODE(SUBSTRING(@SIGN_CHARS, @COUNTER1,1))= UNICODE(SUBSTRING(@strInput,@COUNTER ,1) )
			BEGIN 
				IF @COUNTER=1
					SET @strInput = SUBSTRING(@UNSIGN_CHARS, @COUNTER1,1)+ SUBSTRING(@strInput, @COUNTER+1,LEN(@strInput)-1) 
				ELSE
					SET @strInput = SUBSTRING(@strInput, 1, @COUNTER-1) + SUBSTRING(@UNSIGN_CHARS, @COUNTER1,1) + SUBSTRING(@strInput, @COUNTER+1,LEN(@strInput)- @COUNTER)
					BREAK
			END
			SET @COUNTER1 = @COUNTER1 +1
		END
		SET @COUNTER = @COUNTER +1
	 END
	 SET @strInput = replace(@strInput,' ',' ')
	 RETURN @strInput
END

