<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>

<style type="text/css">
 td {white-space:nowrap;overflow:hidden;text-overflow: ellipsis;}
 table{table-layout:fixed;word-wrap:break-word;}
</style>
<meta charset="UTF-8">
<meta name="viewport"
	content="width=device-width, initial-scale=1, user-scalable=no" />
<link rel='stylesheet'
	href="${pageContext.request.contextPath}/assets/css/main.css">
<title>Studie Hub</title>

</head>




<script>

if("${success}"=="管理員登入成功"){alert('${"管理員登入成功!"}')}

var adminId = "${adminId}";
	// 踢除非管理員
	if(!adminId){
	alert('您不具有管理者權限，請登入後再試。');
	top.location = "<c:url value='/gotoAdminIndex.controller' />";
}
	
	
	

window.onload = function(){
// console.log(adminId);
	
	//如果有登入，隱藏登入標籤
	var loginHref = document.getElementById('loginHref');
	var logoutHref = document.getElementById('logoutHref');
	var userId = document.getElementById('userId');
	var userPic = document.getElementById('userPic');
	if(adminId){
		loginHref.hidden = true;
		logoutHref.style.visibility = "visible";	//有登入才會show登出標籤(預設為hidden)
	}
	
}
	let dataArea = null; //變數放在外面 空值(原始狀態)  放在方法裡 別的方法要用它會找不到 不要讓他被綁住 
	let restname = null;
	let query = null;
 

	window.addEventListener("load", function() {
		//window.addEvenListener 網頁監聽器 
		//當瀏覽器從第一行到最後一行載完畢後才執行 function() 

			
		dataArea = document.getElementById("dataArea");
		restname = document.getElementById("restname");
		query = document.getElementById("query");
		queryall = document.getElementById("queryall");

		//抓到 Id 叫 dataArea 能對這個地方做修改 或 對他做監聽事件
		let xhr = new XMLHttpRequest();
		xhr.open("GET", "<c:url value='/EventfindAll' />", true);
		//他會送出請求去/findAll 然後 controller 去接收 /findAll 執行方法
		//說明請求的內容 fales 就是同步 true 就是非同步 
		xhr.send();
		//真正送出請求
		xhr.onreadystatechange = function() {
			//當屬性發生變化的時候執行方法	
			if (xhr.readyState == 4 && xhr.status === 200) {
                 if("${successMessage}"){
                	 alert("${successMessage}");
                 }
				dataArea.innerHTML = showData(xhr.responseText);
				//執行方法 將 jsoe字串  轉為 jsoe物件 
			}
		};

		query.addEventListener("click", function() {
			//當id= query 的DOM物件被按下後 執行此方法
			let rname = restname.value;
			//取得 id=rname 的DOM物件的值
			if (!rname) {
				alert('請輸入活動名稱,可輸入部分')
				return;
			}

			let xhr2 = new XMLHttpRequest();
			xhr2.open('GET', "<c:url value='/queryEventByName' />?rname=" + rname);
			xhr2.send();
			xhr2.onreadystatechange = function() {
				if (xhr2.readyState == 4 && xhr2.status == 200) {

					console.log(xhr2.responseText);
					
					dataArea.innerHTML = showData(xhr2.responseText);

				}
			}
		});
		
		queryall.addEventListener("click", function() {
			//當id= query 的DOM物件被按下後 執行此方法

			let xhr3 = new XMLHttpRequest();
			xhr3.open('GET', "<c:url value='/EventfindAll' />", true);
			xhr3.send();
			xhr3.onreadystatechange = function() {
				if (xhr3.readyState == 4 && xhr3.status == 200) {

					
					
					dataArea.innerHTML = showData(xhr3.responseText);

				}
			}
		});

	});

	function showData(textobj) {
		// 	改成map回傳 obj裡面變成 物件 有size 跟 list 陣列物件
		// 	let places = JSON.parse(textData);
		// 	將 jsoe字串  轉為 jsoe物件 
		let obj = JSON.parse(textobj)
		let size = obj.size;
		//  分別把物件裡的 size 跟 list 拆開
		let events = obj.list

		let segment = "<table >";

		if (size == 0) {
			segment += "<tr><th colspan='1'>'查無資料'</th><tr>"
		} else {
			segment += "<tr><th colspan='8'>共計" + size + "筆資料</th><tr>";
			segment += "<tr><th>會員帳號</th><th>活動類型</th><th>活動名稱</th><th>報名時間</th><th>活動時間</th><th>活動地址</th><th>活動照片</th><th>活動過期</th></tr>"

			for (n = 0; n < events.length; n++) {
				let event = events[n];
// 				console.log("<td><input type='button'value='刪除'onclick=if(confirm('是否確定刪除("+ event.a_name+ ")'))location='<c:url value = '/updateProduct/"+event.a_aid+"'/>' /></td>")
						

				let tmp0 = "<c:url value = '/updateEvent/'/>" + event.a_aid;
				let tmp1 = "<c:url value = '/deleteEvent/'/>" + event.a_aid;
				// 		let tmp1 = "<a href= '"+tmp1+"'>"+place.name+"</a>";

				// 		let tmp1 = "<c:url value='/modifyRestaurant/'   />" + place.placeId;
				//修改的時候傳帶place.placeId參數的超連結 
				// 		let tmp0 = "<a href= '"+tmp1+"'>"+place.name+"</a>";
				// 		let tmp0 = "<a href= '....'>"+place.name+"</a>";

				//JSON物件 第0個開始
				// 		console.log("tmp0="+tmp0) ; 

				segment += "<tr>"
			    segment += "<td title='"+event.a_uid+"'>" + event.a_uid + "</td>"
				segment += "<td title='"+event.a_type+"'>" + event.a_type + "</td>"
				segment += "<td title='"+event.a_name+"'>" + event.a_name + "</td>"
				segment += "<td title='"+event.a_registration_starttime+"至"+event.a_registration_endrttime+"'>" + event.a_registration_starttime +"至"+event.a_registration_endrttime+ "</td>"			
				segment += "<td title='"+event.a_startTime+"至"+event.a_endTime+"'>" + event.a_startTime +"至"+event.a_endTime+ "</td>"
				segment += "<td title='"+event.a_address+"'>" + event.a_address + "</td>"
				segment += "<td><img width='100' height='60' src='"+ '<c:url value="/" />' + event.a_picturepath+ "'></td>"
				segment += "<td>" + event.expired + "</td>"
				
	
						
// 				segment += "<td><input type='button'value='更新'onclick=\"window.location.href='"+tmp0+"'\" /></td>";

				segment += "<td><input type='button'value='強制下架' style='width:60px;height:50px;font-size:1px;border-radius: 10px;'    onclick=if(confirm('是否確定下架("+ event.a_name + ")'))location='<c:url value = '/deleteadminEvent/"+event.a_aid+"'/>' /></td>"
						

						
				segment += "</tr>"
			}
		}
		segment += "</table>";

		return segment;
	}
</script>

<body class="is-preload">
	<!-- Wrapper -->
	<div id="wrapper">
		<!-- Main -->
		<div id="main">
			<div class="inner">
				<%@include file="../universal/adminHeader.jsp"%>
				<h2 align='center'>管理者活動內容後台</h2>
				
				<div align="center">
					
					<font color='red'>${successMessage}</font>
					<!--   修改成功的重定向帶值 -->
					<div style="text-align: center;">
					<input type="text" id="restname" style="display: inline; width: 300px; "placeholder="請輸入活動關鍵字">
					<button id="query" style="width:60px;height:50px;font-size:1px;border-radius:10px;" >搜尋</button>&nbsp<button id="queryall"  style="width:60px;height:50px;font-size:1px;border-radius:10px;" >搜尋全部</button>
					<br>
					<br>
				</div>
					
				</div>
					


				<div1 id='dataArea'>
<!-- 				插入表單位置 -->
				</div1>
<%-- 				<a href="<c:url value='/'/> ">回前頁</a> --%>
			</div>
		</div>

		<!-- Sidebar -->
		<!-- 這邊把side bar include進來 -->
		<%@include file="../universal/adminSidebar.jsp"%>

	</div>

	<!-- Scripts -->
	<script
		src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
	<script
		src="${pageContext.request.contextPath}/assets/js/browser.min.js"></script>
	<script
		src="${pageContext.request.contextPath}/assets/js/breakpoints.min.js"></script>
	<script src="${pageContext.request.contextPath}/assets/js/util.js"></script>
	<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>

</body>
</html>






