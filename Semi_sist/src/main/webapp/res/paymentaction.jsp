<%@page import="data.dao.ScheduleDao"%>
<%@page import="data.dao.ResDao"%>
<%@page import="data.dto.ResDto"%>
<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
<script src = "https://code.jquery.com/jquery-3.5.0.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
<link href="https://fonts.googleapis.com/css2?
family=Dokdo&family=Gaegu&family=Gugi&family=Nanum+Pen+Script&display=swap" rel="stylesheet">

</head>
<body>
<script language="JavaScript1.2">
top.document.title = 'TasteBook';
</script>
<%
String login_num = request.getParameter("login_num"); //로그인 번호
String shop_num = request.getParameter("shop_num"); //가게 번호
String shop_name = request.getParameter("shop_name"); //가게 상호명
String res_date = request.getParameter("res_date"); //예약날짜
String persons = request.getParameter("persons"); //인원수
String price = request.getParameter("price"); //결제금액
String seat = request.getParameter("seat"); //좌석
seat = seat.substring(0, 1); //좌석

//세션으로 부터 ID 얻기
//ID를 이용해서 로그인 번호 불러오기

ResDto dto = new ResDto();

dto.setLogin_num(login_num);
dto.setShop_num(shop_num);
dto.setShop_name(shop_name);
dto.setRes_date(res_date);
dto.setPersons(persons);
dto.setPrice(price);
dto.setSeat(seat);

ResDao dao = new ResDao();
dao.insertRes(dto);

ScheduleDao sdao = new ScheduleDao();

String sdate = res_date.substring(0, 10);
String ampm = res_date.substring(14, 16);
String time = res_date.substring(17, 18);
int inttime = Integer.parseInt(time);
String stime = "";


if(ampm.equals("오후")){
	stime = String.valueOf((inttime += 12));
}



System.out.println(sdate);
System.out.println(shop_num);
System.out.println(stime);
System.out.println(seat);

if(seat.equals("룸")){
	//스케쥴 테이블 room_cnt +1 증가 dao
	sdao.updateRoom(sdate, shop_num, stime);
} else {
	//스케쥴 테이블 hall_cnt +1 증가 dao
	sdao.updateHall(sdate, shop_num, stime);
}

response.sendRedirect("../realindex.jsp?main=res/completeform.jsp");
%>
</body>
</html>