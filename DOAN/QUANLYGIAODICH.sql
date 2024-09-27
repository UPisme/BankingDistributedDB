---THỐNG KÊ SỐ LƯỢNG GIAO DỊCH CỦA TÀI KHOẢN
CREATE PROC sp_SLGiaoDichCuaTK 
    @SOTK VARCHAR(10), 
    @NGAYBD DATETIME,
	@NGAYKT DATETIME
AS
BEGIN
	IF DATEDIFF(day, @NGAYBD, @NGAYKT) > 30
    BEGIN
        RAISERROR(N'Khoảng thời gian không được quá 30 ngày', 16, 1)
        RETURN
    END
	ELSE IF DATEDIFF(day, @NGAYBD, @NGAYKT) < 0
	BEGIN
		RAISERROR(N'Thời gian kết thúc phải lớn hơn thời gian bắt đầu', 16, 1)
        RETURN
	END

    DECLARE @GD_CN INT = 0, @GD_GUI INT = 0, @GD_RUT INT = 0, @TONGSOGD INT = 0
    
    SET @GD_CN = (
		SELECT COUNT(*) 
		FROM GD_CHUYENNHAN 
		WHERE 
			 SOTK_GUI = @SOTK 
			 AND NGAYGD >= @NGAYBD
			 AND NGAYGD <= @NGAYKT
			)
    
    SET @GD_GUI = (
		SELECT COUNT(*) 
        FROM GD_GOIRUT 
        WHERE 
             LOAIGD = 'GT' 
             AND SOTK = @SOTK 
             AND NGAYGD >= @NGAYBD
			 AND NGAYGD <= @NGAYKT
        )
    
    SET @GD_RUT = (
		SELECT COUNT(*) 
        FROM GD_GOIRUT 
        WHERE 
             LOAIGD = 'RT' 
             AND SOTK = @SOTK 
             AND NGAYGD >= @NGAYBD
			 AND NGAYGD <= @NGAYKT
        )
    
    SET @TONGSOGD = @GD_CN + @GD_GUI + @GD_RUT
    
    SELECT 
        N'CHUYỂN TIỀN' AS PhanLoai,
        @GD_CN AS SoLuong
    UNION
    SELECT 
        N'GỬI TIỀN' AS PhanLoai,
        @GD_GUI AS SoLuong
    UNION
    SELECT 
        N'RÚT TIỀN' AS PhanLoai,
        @GD_RUT AS SoLuong
	UNION
    SELECT 
        N'TỔNG SỐ GIAO DỊCH' AS PhanLoai,
        @TONGSOGD AS SoLuong
 
END

SELECT *FROM GD_CHUYENNHAN
SELECT *FROM GD_GOIRUT
GO
EXEC sp_SLGiaoDichCuaTK '0946822351', '2024-02-14','2024-03-11'


---DANH SÁCH GIAO DỊCH THEO LOẠI GIAO DỊCH VÀ NGÀY

GO
CREATE PROC sp_DanhSachGiaoDichCuaKH 
    @SOTK VARCHAR(10), 
    @NGAYBD DATETIME,
	@NGAYKT DATETIME, 
    @LOAIGD VARCHAR(10)
AS
BEGIN
	IF DATEDIFF(day, @NGAYBD, @NGAYKT) > 30
    BEGIN
        RAISERROR(N'Khoảng thời gian không được quá 30 ngày', 16, 1)
        RETURN
    END
	ELSE IF DATEDIFF(day, @NGAYBD, @NGAYKT) < 0
	BEGIN
		RAISERROR(N'Thời gian kết thúc phải lớn hơn thời gian bắt đầu', 16, 1)
        RETURN
	END

    IF @LOAIGD = 'CT' 
    BEGIN
        SELECT MAGD, SOTK_GUI, SOTK_NHAN, SOTIEN, NGAYGD, MANV
        FROM GD_CHUYENNHAN 
        WHERE SOTK_GUI = @SOTK 
			AND NGAYGD >= @NGAYBD
			AND NGAYGD <= @NGAYKT
    END
    ELSE IF @LOAIGD = 'GT' OR @LOAIGD = 'RT' 
    BEGIN
        SELECT MAGD, SOTK, SOTIEN, NGAYGD, MANV
        FROM GD_GOIRUT 
        WHERE SOTK = @SOTK 
			AND NGAYGD >= @NGAYBD
			AND NGAYGD <= @NGAYKT
          AND LOAIGD = @LOAIGD;
    END
END


EXEC sp_DanhSachGiaoDichCuaKH '0946822351','2024-02-14','2024-03-11', 'RT'

EXEC sp_DanhSachGiaoDichCuaKH '0946822351', '2024-02-14','2024-03-11', 'CT';

EXEC sp_DanhSachGiaoDichCuaKH '0946822351', '2024-02-14','2024-03-11', 'GT';


