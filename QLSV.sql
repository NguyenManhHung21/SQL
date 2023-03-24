create database QLSINHVIEN;
use QLSINHVIEN;

create table Student (
	IdStd int primary key not null IDENTITY(1,1),
	NameStd nvarchar(20) not null,
	Birthday date,
	Gender varchar(5),
	IdFaculty int,
	constraint FK_FacultyStudent  foreign key (IdFaculty)
	references Faculty(IdFaculty)
); 
delete from Student;
drop table Student
create table Faculty (
	IdFaculty int primary key not null,
	IndexFaculty varchar(10) not null,
	NameFaculty varchar(20) not null
)

insert into Faculty values (01, 'cnttcn', 'CNTT');
insert into Faculty values (02, 'dtvtcn', 'ĐTVT');

insert into Student values('Hung', '03-22-2001', 'Nam', 02);
insert into Student values('Manh', '02-02-2000', 'Nam', 02);
insert into Student values('Dong', '01-09-2001', 'Nam', 02);
insert into Student values('Cuong', '12-22-2002', 'Nam', 02);
insert into Student values('Hai', '03-22-2002', 'Nam', 02);

insert into Student values('Minh', '03-11-2001', 'Nam', 01);
insert into Student values('Anh', '03-11-2001', 'Nam', 01);
insert into Student values('Hoang', '10-04-2001', 'Nam', 01);
insert into Student values('Nam', '03-22-2001', 'Nam', 01);
insert into Student values('Hieu', '12-22-2001', 'Nam', 01);
insert into Student values('Thong', '12-05-2001', 'Nam', 01);
insert into Student values('Thai', '03-12-2001', 'Nam', 01);
insert into Student values( 'Dac', '03-22-2001', 'Nam', 01);
insert into Student values('Nhi', '03-22-2001', 'Nu', 01);
insert into Student values('Dung', '03-22-2001', 'Nam', 01);
insert into Student values('Tao', '11-04-2001', 'Nam', 01);
insert into Student values('Long', '03-12-2001', 'Nam', 01);
insert into Student values('Hieu', '03-01-1998', 'Nam', 01);
insert into Student values('Uyen', '12-22-2002', 'Nu', 01);
insert into Student values('Anh', '03-22-2001', 'Nu', 01);

--đếm số lượng SV
select count(IdStd) from Student;


--Đếm số lượng sinh viên theo KHOA
select count(IdStd) from Student where IdFaculty = 01;

--Lấy danh sách sinh viên khoa CNTT
select * from Student where IdFaculty = 01;

--Lấy danh sách sinh viên khoa CNTT là nữ
select * from Student where IdFaculty = 01 and Gender = 'Nu';

-- Lấy danh sách sinh viên khoa CNTT là nữ và sinh từ tháng 7 trở ra
select * from Student where IdFaculty = 01 and Gender = 'Nu' and Month(Birthday) > 7; 

--Lấy danh sách sinh viên nhóm theo hai khoa (GROUP BY) với điều kiện chung GIOI_TINH là Nam
select Faculty.NameFaculty, Student.IdStd, Student.NameStd, Student.Birthday, Student.Gender as 'Number of Student' from Student
inner join Faculty on Student.IdFaculty = Faculty.IdFaculty where Student.Gender = 'Nam'
group by NameFaculty, IdStd, NameStd , Birthday, Gender;

--Viết function: Tạo hàm fn_LayMaVaTenSinhVien (gộp MA_SINH_VIEN và TEN_SINH_VIEN có dấu " - " phân cách.
create function fn_LayMaVaTenSinhVien(@idStd int, @nameStd varchar(20))
returns varchar(50)
as
begin
	declare @IdAndName varchar(50) --khởi tạo ra 1 string để lưu trữ
	select @IdAndName = cast(IdStd as char(5)) + ' - ' + NameStd  --gán format mà mình muốn cho @IdAndName
	from Student
	where IdStd = @idStd and NameStd = @nameStd;
	return @IdAndName
end

drop function dbo.fn_LayMaVaTenSinhVien 
select dbo.fn_LayMaVaTenSinhVien(2, 'Manh') as 'Id and Name of Student';

--- Viết stored procedure: Tạo các thủ tục sp_ThemSinhVien; sp_SuaTTSinhVien; 
-- sp_XoaSinhVien (xóa 1 sinh viên theo SINH_VIEN_ID); sp_TimKiemSinhVien 
-- (với điều kiên tìm gần đúng MA_SINH_VIEN, TEN_SINH_VIEN, GIOI_TINH, NGAY_SINH từ ngày - đến ngày)
create proc sp_ThemSinhVien
(
	@nameStd varchar(20),
	@birthday date,
	@gender varchar(5),
	@idFaculty int
)
as
begin 
	insert into Student values  (@nameStd, @birthday, @gender,@idFaculty)
end

--Sua
create proc sp_SuaTTSinhVien(
	@idStd int,
	@nameStd varchar(20),
	@birthday date,
	@gender varchar(5),
	@idFaculty int
)
as
begin
	if(exists(select * from Student where @idStd = IdStd))
		update Student set NameStd = @nameStd, Birthday = @birthday, 
		Gender = @gender, IdFaculty = @idFaculty where @idStd = IdStd;
	else
		print N'Không tìm thấy SV có id là: ' + @idStd + ' trong bảng!';
end

--Xoa
create proc sp_XoaSinhVien(@idStd int)
as 
begin
	if(exists(select * from Student where @idStd = IdStd))
		delete Student where @idStd = IdStd
	else 
		print N'Không tìm thấy SV có id là: ' + @idStd + ' trong bảng!';
end

-- Tìm gần đúng MA_SINH_VIEN, TEN_SINH_VIEN, GIOI_TINH, NGAY_SINH từ ngày - đến ngày
create proc sp_TimKiemSinhVien(
@idStd int = null,
@nameStd varchar(20) = null,
@startDay date = null,
@endDay date = null,
@gender varchar(5) = null
)
as
begin
	select IdStd, NameStd, Birthday, Gender, IdFaculty  from Student 
		where 
		(@idStd = IdStd or @idStd is null)
		and (NameStd like '%' + @nameStd + '%' or @nameStd is null)
		and (CAST(@startDay as date) <= Birthday or @startDay is null)
		and (CAST(@endDay as date) >= Birthday  or @endDay is null)
		and (Gender = @gender or @gender is null)
end


drop proc sp_ThemSinhVien
--Them
exec sp_ThemSinhVien 'Dola', '2001-03-17', 'Nu', 02;
--Sua
exec sp_SuaTTSinhVien 1, 'Trang', '2004-03-11', 'Nu', 01;

--Xoa
exec sp_XoaSinhVien 1

--Tim kiem
exec sp_TimKiemSinhVien @startDay = '2001-03-01', @endDay = '2001-03-18';