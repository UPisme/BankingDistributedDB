-- KHÁCH HÀNG --
---- In DSKH
EXEC sp_CustomersList -- CN hiện hành
EXEC QLNH_LINK.QLNGANHANG.dbo.sp_CustomersList -- CN còn lại

---- Tìm kiếm KH theo CCCD
EXEC sp_CustomerSearch '079123456789'
EXEC QLNH_LINK.QLNGANHANG.dbo.sp_CustomerSearch '079234567891'

---- Thêm KH
SELECT * FROM KHACHHANG
EXEC sp_AddCustomer N'TRẦN THỊ', N'THU', '1986-01-27', 0, '078234567891', '0364989876', N'Chung cư Lý Thường Kiệt, P7, Q11, TPHCM' -- KH đã có ở CN1
EXEC sp_AddCustomer N'TRẦN THỊ', N'THU', '1986-01-27', 0, '078789123456', '0364989876', N'Chung cư Lý Thường Kiệt, P7, Q11, TPHCM' -- KH đã có ở CN1
EXEC sp_AddCustomer N'TRẦN THỊ', N'THU', '1986-01-27', 0, '079123456788', '0234567891', N'Chung cư Lý Thường Kiệt, P7, Q11, TPHCM' -- SDT đã tồn tại
EXEC sp_AddCustomer N'TRẦN THỊ', N'THU', '1986-01-27', 0, '079123456788', '0674567891', N'Chung cư Lý Thường Kiệt, P7, Q11, TPHCM'

---- Xóa KH
SELECT * FROM KHACHHANG
EXEC sp_DeleteCustomer '079123456788'


-- QUẢN LÝ TKNH --
---- Tìm kiếm TKNH
EXEC sp_searchTKNH @stk = '0789123456'
EXEC sp_searchTKNH @makh = 'KH0008'
EXEC sp_searchTKNH @ngaytao = '2024-01-15'
EXEC sp_searchTKNH @ngaytao = '2024-01-15', @stk ='0981357462'

---- Thêm TKNH
EXEC sp_KiemTraTKNH '078789323456', '0985713246', 'abcd' -- TH chưa tồn tại KH (CCCD ko có trong db)
EXEC sp_KiemTraTKNH '078789123456', '0985713246', 'abcd' -- TH SOTK đã tồn tại
EXEC sp_KiemTraTKNH '078789123456', '0985713265', 'abcd'
SELECT * FROM TKNH

---- Xóa TKNH
SELECT * FROM TKNH
EXEC sp_deleteTKNH '0985713265'


-- GIAO DỊCH --
---- Chuyển tiền
SELECT * FROM TKNH
SELECT * FROM GD_CHUYENNHAN
EXEC sp_GiaoDichCT '0123456649', '0789123456', 1150000, 'NV003' -- TH STK gửi ko có trong db
EXEC sp_GiaoDichCT '0678912345', '0789123776', 1150000, 'NV003' -- TH STK nhận ko có trong db
EXEC sp_GiaoDichCT '0789123456', '0234567891', 5000, 'NV003' -- TH số tiền gửi quá nhỏ
EXEC sp_GiaoDichCT '0789123456', '0234567891', 1000000, 'NV003'

---- Gởi tiền
SELECT * FROM TKNH
SELECT * FROM GD_GOIRUT
EXEC sp_GiaoDichGT '0123456649', 50000, 'NV002' -- TH STK ko tồn tại
EXEC sp_GiaoDichGT '0345678912', 50000, 'NV002'

---- Rút tiền
SELECT * FROM TKNH
SELECT * FROM GD_GOIRUT
EXEC sp_GiaoDichRT '0924681235', 50000, 'NV002' -- TH ko đủ số dư
EXEC sp_GiaoDichRT '0345678912', 50000, 'NV002'


-- QUẢN LÝ GIAO DỊCH --
---- Số lượng giao dịch của 1 TKNH trong khoảng thời gian nhất định (tối đa 30 ngày)
EXEC sp_SLGiaoDichCuaTK '0345678912', '2024-02-25', '2024-03-28' -- TH vượt số ngày tối đa
EXEC sp_SLGiaoDichCuaTK '0345678912', '2024-02-29', '2024-02-28' -- TH tgian ko hợp lí
EXEC sp_SLGiaoDichCuaTK '0345678912', '2024-02-29', '2024-03-28'

---- DS giao dịch của 1 TKNH trong khoảng thời gian nhất định (tối đa 30 ngày)
EXEC sp_DanhSachGiaoDichCuaKH '0946822351', '2024-02-14', '2024-03-11', 'RT'
EXEC sp_DanhSachGiaoDichCuaKH '0946822351', '2024-02-14', '2024-03-11', 'CT'
EXEC sp_DanhSachGiaoDichCuaKH '0946822351', '2024-02-14', '2024-03-11', 'GT'


