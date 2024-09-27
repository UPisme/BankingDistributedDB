create proc sp_searchTKNH
	@stk varchar(10) = null,
	@makh varchar(10) = null,
	@ngaytao date = null
as
begin
	select SOTK, TENTK, NGAYTAO, SODU, TRANGTHAI, MAKH, MATKHAU 
	from TKNH
	where (@stk is null or SOTK = @stk) 
		and  (@makh is null or MAKH = @makh )
		and (@ngaytao is null or NGAYTAO = @ngaytao)
end
go

exec sp_searchTKNH @stk = '0789123456'
exec sp_searchTKNH @makh = 'KH0008'
exec sp_searchTKNH @ngaytao = '2024-01-15'
exec sp_searchTKNH @ngaytao = '2024-01-15', @stk ='0981357462'

go
ALTER proc sp_deleteTKNH
	@stk varchar(10)
as
begin
	UPDATE TKNH
	SET TRANGTHAI = 0
	WHERE SOTK = @stk
end
