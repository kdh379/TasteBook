<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.time.LocalDate"%>
<%@page import="data.dao.ScheduleDao"%>
<%@page import="data.dao.LoginDao"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="data.dao.ReviewDao"%>
<%@page import="data.dto.ReviewDto"%>
<%@page import="java.util.Vector"%>
<%@page import="data.dto.MenuDto"%>
<%@page import="data.dao.MenuDao"%>
<%@page import="data.dao.ShopDao"%>
<%@page import="data.dto.ShopDto"%>
<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
<script src="https://code.jquery.com/jquery-3.5.0.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
<link href="https://fonts.googleapis.com/css2?family=Gamja+Flower&family=Nanum+Pen+Script&display=swap"
rel="stylesheet">
<style type="text/css">
h3{
	margin-top: 70px;
	
}

hr{
	
	border: 0;
    height: 1px;
    background: #ccc;
    width: 800px;
    
    float: left;
    margin-bottom: 20px;
}

table#info{
	margin-bottom: 10px;
}

table#info tr{
	line-height: 30px;
}

table#info tr th{
	color: #a9a9a9  ;
}

table#info tr td{
	font-size: 11pt;
	
} 

div#map{
	
	margin-right: 5%;
	
}




</style>

<!-- Favicon 즐겨찾기 아이콘(favorites icon)-->
<link rel="icon" type="image/x-icon" href="../assets/logo1.ico" />
</head>
<%

request.setCharacterEncoding("utf-8");

//shop의 num
String num = request.getParameter("num");   //shop의num

//shop dao생성
ShopDao shdao = new ShopDao();
ShopDto shdto = shdao.getOneShop(num);

//menu dao 생성
MenuDao mdao = new MenuDao();
Vector<MenuDto> mlist = mdao.getMenu(num);

//review dao생성
ReviewDao rdao = new ReviewDao();

int totalCount;  //총 글수
int totalPage;   //총 페이지수
int startPage;   //각 블럭의 시작페이지
int endPage;   //각 블럭의 끝페이지
int start;   //각페이지의 시작번호
int perPage=3;  //한페이지에 보여질 글수
int perBlock=3;  //한페이지에 보여지는 페이지 개수
int currentPage;  //현재페이지
int no;

//총개수
totalCount=rdao.getTotalCount(num);


//현재페이지번호 읽기(단 null일경우 1페이지 설정)
if(request.getParameter("currentPage")==null){
	currentPage=1;
}else{
	currentPage=Integer.parseInt(request.getParameter("currentPage"));
}

//총페이지개수구하기
totalPage = totalCount/perPage + (totalCount%perPage==0?0:1);

//각블럭의 시작페이지
//예: 현재페이지:3, startPage:1,endPage:5
//예: 현재페이지:6, startPage:6,endPage:10;
startPage = (currentPage-1)/perBlock*perBlock+1;
endPage = startPage+perBlock-1;

//만약 총페이지수가 8일경우
//2번째 블럭은 start:6, endPage:10되야?
//이때는 endpage를 8로 수정해준다
if(endPage>totalPage){
	endPage=totalPage;
}

//각 페이지에서 불러올 시작번호
//현재페이지가 1 일경우 start는 1,  2일 경우6...
start=(currentPage-1)*perPage;

//각페이지에서 필요한 게시글 가져오기...dao에서 만든거+해당 음식점의 리뷰들중에서!
Vector<ReviewDto> rlist = rdao.getList(start, perPage, num);

//각 글앞에 붙힐 시작번호 구하기
//총글이 20개일경우 1페이지는 20, 2페이지는 15부터
//출력해서 1씩 감소해가며 출력할것
no = totalCount-(currentPage-1)*perPage;



SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
//로그인dao생성
LoginDao ldao = new LoginDao();

//sdate변경 테스트
ScheduleDao scdao = new ScheduleDao();
scdao.updateSdate();
LocalDate yesterday = LocalDate.now().minusDays(1);
LocalDate fourdays = LocalDate.now().plusDays(4);
//System.out.println(yesterday.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"))); 
//System.out.println(fourdays.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"))); 


//세션아이디 얻기
String myid = (String) session.getAttribute("myid");
String loginok = (String) session.getAttribute("loginok");
%>

<body>
<script language="JavaScript1.2">
top.document.title = 'TasteBook | 상세페이지';
</script>
<!-- 음식점정보 + 리뷰게시판 -->
<div class="main" style="width: 800px; padding: 10px; display: block; margin-right: auto; margin-left: auto;" >
<b style="font-size: 20pt;"><%=shdto.getName() %></b><font color="#ff4500 " style="margin-left: 20px; clear: both; font-size: 22pt;">
<%=shdto.getAvg() %></font>

<button type="button" class="btn btn-info" style="margin-left: 600px; margin-top: -60px;"
 onclick="location.href='shop/checklogin.jsp?shop_num=<%= num%>'">예약하기</button>
   
<hr>

<div style="clear: both;"></div>

<!-- 음식점 정보 -->
<table id="info" style="width: 700px; float: left;">
  <tr>
    <th width="100px">주소</th>
    <td colspan="2"><%=shdto.getAddr() %></td>
    <td rowspan="5+<%=mlist.size()%>" align="right">
      
  <div id="map" style="width:300px;height:200px;"></div>

    </td>
  </tr>
  
  <tr>
    <th width="100px">전화번호</th>
    <td colspan="2"><%=shdto.getTelephone() %></td>
  </tr>
  
  <tr>
    <th width="100px">음식 종류</th>
    <td colspan="2"><%=shdto.getTag() %></td>
  </tr>
  
  <tr>
    <th width="100px">주차</th>
    <td colspan="2">주차 공간 <%=shdto.getParking() %></td>
  </tr>
  
  <tr>
    <th width="100px">영업 시간</th>
    <td colspan="2"><%=Integer.toString(shdto.getOpening())  %>:00 - <%=Integer.toString(shdto.getClosing())  %>:00</td>
  </tr>
  
  <tr>
  <th width="100px" rowspan="<%=mlist.size() %>" style="vertical-align: top;">메뉴</th>
  <%
  for(int i=0; i<mlist.size(); i++){
	  
	  MenuDto mdto = mlist.get(i);
  
  %>
	  
  <td><%=mdto.getMenu() %></td>
  <td align="right"><%=mdto.getPrice() %>원</td>
    
    <%-- <td><%=mdto.getMenu() %>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=mdto.getPrice() %>원</td> --%>
    
  </tr>
  

	  
  <%}
  
  
  %>
  
  


</table>
<%
String []star = {"☆☆☆☆☆","★☆☆☆☆","★★☆☆☆","★★★☆☆","★★★★☆","★★★★★"};
%>
<hr>

<div style="clear: both;" class="review">

<h4><b>리뷰</b>&nbsp;(<%=rdao.getTotalCount(num) %>)</h4>  <!-- totalCount %> -->
<!-- 리뷰게시판 -->
<table style="margin-top: 30px;">
  <%
  for(int i=0; i<rlist.size(); i++){    /* rlist.size()까지로 */
	  
	  ReviewDto rdto = rlist.get(i);
	  String logPhoto = ldao.getOneData(rdto.getLogin_num()).getPhoto();
	  int score = Integer.parseInt(rdto.getScore());
	  %>
	  
  <tr>
    <th width="120px;" style="vertical-align: top; text-align: center">
    <!-- save/ logPhoto  -->
      <img alt="" src="save/<%=logPhoto %>" style="border-radius: 100px; width: 60px; height: 60px; border: 1px solid black"><br>
      <font style="font-size: 8px;" ><%=ldao.getOneData(rdto.getLogin_num()).getNick() %></font>  <!-- ldao.getOneData(rdto.getLogin_num()).getNick() -->
    </th>
    
    <td width="700px;" style="line-height: 25px;">
      <font color="#ffd700" ><%=star[score] %></font>
      <br>
      <font color="#a9a9a9 "><%=sdf.format(rdto.getWriteday()) %></font>  <!-- sdf.format(rdto.getWriteday()) -->
       <%
          
	      String id = ldao.getOneData(rdto.getLogin_num()).getId();
	      //로그인한 아이디와 글쓴 아이디가 같을경우에만 삭제/수정 가능
	      
	      if(loginok!=null && id.equals(myid)){%>
	    	 
	    	 |<a href="realindex.jsp?main=shop/reviewupdateform.jsp?currentPage=<%=currentPage %>&num=<%=rdto.getNum() %>" 
	    	 style="color: blue;">수정</a>   <!-- currentpage와 num(rdto.getNum())넘겨주면서 review수정폼으로 가기 -->
	    	 |<a href="shop/reviewdelete.jsp?currentPage=<%=currentPage %>&num=<%=rdto.getNum() %>" 
	    	 style="color: red;">삭제</a>   <!-- currentpage와 num넘겨주면서 review삭제액션으로 가기 -->
	    	  
	      <%}
	      
	      %>
      <br> 
      <%= rdto.getContent() %>
      <br>
       <!-- content에 사진포함 -->  
      
    </td>
  
  </tr>
  <tr>
    <td colspan="2">
    <hr style="margin-left: 0px;">
    </td>
  </tr>
  
  <%}
  
  
  %>
  


</table>
</div>

<!-- 페이징처리 -->
<div class="container">
  <ul class="pagination" style="margin-top: -5px;">
  <%
  //이전
  if(startPage>1){
	  %>
	  <li>
	    <a href="realindex.jsp?main=shop/shopform.jsp?currentPage=<%=startPage-1%>&num=<%=num%>">이전</a>
	  </li>
  <%}
  %>
    <%
    for(int p=startPage; p<=endPage; p++){
    	if(p==currentPage){%>
    		<li class="active">
    		  <a href="realindex.jsp?main=shop/shopform.jsp?currentPage=<%=p%>&num=<%=num%>"><%=p %></a>
    		</li>
    	<%}else{%>
    		<li>
    		  <a href="realindex.jsp?main=shop/shopform.jsp?currentPage=<%=p%>&num=<%=num%>"><%=p %></a>
    		</li>
    	<%}
    }
    
    //다음
    if(endPage<totalPage){%>
    	
    	<li>
    	  <a href="realindex.jsp?main=shop/shopform.jsp?currentPage=<%=endPage+1%>&num=<%=num%>">다음</a>
    	</li>
    <%}
    
    %>
  
  </ul>

</div>



</div>
<!-- 카카오맵 -->
<!-- <div class="kakao" style=" float: left; margin-top: 60px; margin-left: 50px;;
background-color: #ccc;">
  <div id="map" style="width:400px;height:300px;"></div>
</div> -->
	<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=ce57a245894a14227a15fecd0184864b&libraries=services"></script>
	<script>
	
		/* var container = document.getElementById('map');
		var options = {
			center: new kakao.maps.LatLng(33.450701, 126.570667),
			level: 3
		};

		var map = new kakao.maps.Map(container, options);
		
		// 마커가 표시될 위치입니다 
		var markerPosition  = new kakao.maps.LatLng(33.450701, 126.570667); 

		// 마커를 생성합니다
		var marker = new kakao.maps.Marker({
		    position: markerPosition
		});

		// 마커가 지도 위에 표시되도록 설정합니다
		marker.setMap(map); */
		
		var mapContainer = document.getElementById('map'), // 지도를 표시할 div 
	    mapOption = {
	        center: new kakao.maps.LatLng(33.450701, 126.570667), // 지도의 중심좌표
	        level: 3 // 지도의 확대 레벨
	    };  

	// 지도를 생성합니다    
	var map = new kakao.maps.Map(mapContainer, mapOption); 

	// 주소-좌표 변환 객체를 생성합니다
	var geocoder = new kakao.maps.services.Geocoder();

	// 주소로 좌표를 검색합니다
	geocoder.addressSearch('<%=shdto.getAddr()%>', function(result, status) {

	    // 정상적으로 검색이 완료됐으면 
	     if (status === kakao.maps.services.Status.OK) {

	        var coords = new kakao.maps.LatLng(result[0].y, result[0].x);

	        // 결과값으로 받은 위치를 마커로 표시합니다
	        var marker = new kakao.maps.Marker({
	            map: map,
	            position: coords
	        });

	        // 인포윈도우로 장소에 대한 설명을 표시합니다
	        var infowindow = new kakao.maps.InfoWindow({
	            content: '<div style="width:150px;text-align:center;padding:6px 0;"><%= shdto.getName()%></div>'
	        });
	        infowindow.open(map, marker);

	        // 지도의 중심을 결과값으로 받은 위치로 이동시킵니다
	        map.setCenter(coords);
	    } 
	});    
	</script>


</body>
</html>