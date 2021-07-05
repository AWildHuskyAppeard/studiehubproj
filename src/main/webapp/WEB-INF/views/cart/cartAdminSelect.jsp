<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
<link rel='stylesheet' href="${pageContext.request.contextPath}/assets/css/main.css">
<title>Studie Hub</title>

<script>
if("${successMessageOfChangingPassword}"=="修改成功"){alert('密碼修改成功!');}

var u_id = "${loginBean.u_id}";
var userPicString = "${loginBean.pictureString}";

window.onload = function(){
    var logout = document.getElementById("logout");
    logout.onclick = function(){
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "<c:url value='/logout.controller' />", true);
        xhr.send();
        xhr.onreadystatechange = function(){
            if(xhr.readyState == 4 && xhr.status == 200){
                var result = JSON.parse(xhr.responseText);
                if(result.success){
                    alert(result.success);
                    top.location = '<c:url value='/' />';
                }else if(result.fail){
                    alert(result.fail);                    
                    top.location = '<c:url value='/' />';
                }
            }
        }
    }
    
    //如果有登入，隱藏登入標籤
    var loginHref = document.getElementById('loginHref');
    var signupHref = document.getElementById('signupHref');
    var logoutHref = document.getElementById('logoutHref');
    var userPic = document.getElementById('userPic');
    if(u_id){
    	loginHref.hidden = true;
    	signupHref.hidden = true;
    	logoutHref.style.visibility = "visible";	//有登入才會show登出標籤(預設為hidden)
    	userPic.src = userPicString;	//有登入就秀大頭貼
    }
    
}
</script>

</head>

<body class="is-preload">

		<!-- Wrapper -->
			<div id="wrapper">

				<!-- Main -->
					<div id="main">
						<div class="inner">

							<!-- Header -->
							<!-- 這邊把header include進來 -->
								<%@include file="../universal/header.jsp" %>
								
								
								<h1>管理者頁面</h1>
								<input type='text' id='searchBar'><label for='searchBar'>模糊搜尋：</label><button type="submit" id="searchBtn">查詢</button>
								<select id='searchBy'>
									<option value='o_id' selected>以帳單編號(o_id)</option>
									<option value='p_id'>以課程代號(p_id)</option>
									<option value='p_name'>以課程名稱(p_name)</option>
									<option value='u_id'>以使用者帳號(u_id)</option>
									<option value='u_lastname'>以使用者姓氏(u_lastname)</option>
									<option value='u_firstname'>以使用者名字(u_firstname)</option>
									<!-- <option value='o_status'>以訂單狀態(o_status)</option>❗ -->
									<option value='o_date'>以訂單日期(o_date)</option>
								</select>
								<hr id="pageHref">
								<form>
									<h1 id='topLogo'>以下顯示的是資料庫的至多100筆訂單</h1>
									<!-- 秀出所有Order_Info (希望之後能每20項分一頁) -->
									<table border="2px">
										<thead id="headArea"></thead>
										<tbody id="dataArea"></tbody>
									</table>
									<h1 id='logo' style="background-color: red"></h1>
									<hr>
									
								</form>
								<button name="todo" id="insert" value="insertAdmin" 
								onclick="location.href='http:\/\/localhost:8080/studiehub/cart.controller/cartAdminInsert'">新增</button>
								<button name="todo" id="delete" value="deleteAdmin">刪除勾選資料</button>
								<button id="testxx" hidden="true">測試</button>
								<hr>
								<form>
									<button formmethod="GET" formaction="<c:url value='/' />">回首頁</button>
									<button formmethod="GET" formaction="<c:url value='/cart.controller/cartIndex' />">回購物車使用者首頁</button>
								</form>
								

								

						</div>
					</div>

				<!-- Sidebar -->
				<!-- 這邊把side bar include進來 -->
				<%@include file="../universal/sidebar.jsp" %>  

			</div>

		<!-- Scripts -->
			<script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
			<script src="${pageContext.request.contextPath}/assets/js/browser.min.js"></script>
			<script src="${pageContext.request.contextPath}/assets/js/breakpoints.min.js"></script>
			<script src="${pageContext.request.contextPath}/assets/js/util.js"></script>
			<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>

		<!--********************************** M      Y      S      C      R      I      P      T ******************************************-->
			<script>
				// 不用等DOM就可以先宣告的變數們
				let segments = [];
				let counter = 0;
				let pageNum = 0;
				let rowNum = 0;
				// let dateFormat = /^(((199\d)|(20[0-1]\d)|(20(2[0-1])))\-((0\d)|(1[0-2]))\-(([0-2]\d)|(3[0-1])))( )((([0-1]\d)|(2[0-3])):[0-5]\d:[0-5]\d\.\d)$/;
				// 從1990-01-01到2021-12-31 // 沒有防大小月和２月
				
				$(function(){
					let logo = $('#logo');
					let dataArea = $('#dataArea');
					let headArea = $('#headArea');
					let pageHref = $('#pageHref');
					let searchBy = $('#searchBy');
					let searchBar = $('#searchBar');
					/*********************************************************************************************************/
					
					// 【自訂函數 1】go to UPDATE page
					function toUpdatePage(oid){
						// let url = "<c:url value='/cart.controller/cartAdminUpdate/' />" + oid; // ❓
						let url = "http://localhost:8080/studiehub/cart.controller/cartAdminUpdate/" + oid;
						console.log(url);
						top.location = url;
					}
					
					// 【自訂函數 2】分頁掛資料
					
					function switchPage(pageIndex){
						let htmlStuff = "";
						counter = pageIndex * 10;
						let tempCounter0 = (counter + 10 > segments.length)? segments.length : counter + 10;
						for(let i = counter; i < tempCounter0; i++){
							htmlStuff += segments[i];
						}
						dataArea.html(htmlStuff);
					}
					

					
					
					// 【自訂函數 3】模糊搜尋
					$('#searchBtn').on('click', function(){
						let xhr = new XMLHttpRequest();
						let queryString = 'searchBy=' + searchBy.val() + '&searchBar=' + searchBar.val();
						console.log(queryString);
						xhr.open('POST', "<c:url value='/cart.controller/adminSearchBar' />", true);
						xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded"); // ❓
						xhr.send(queryString);
						xhr.onreadystatechange = function() {
							if (xhr.readyState == 4 && xhr.status == 200) {
								dataArea.html("");
								pageHref.html("");
								// 解析&暫存回傳資料
								parseSelectedRows(xhr.responseText);
								// 掛資料
								let htmlStuff = "";
								let tempCounter0 = (counter + 10 > segments.length)? segments.length : counter + 10;
								for(let i = counter; i < tempCounter0; i++){
									htmlStuff += segments[i]
								}
								dataArea.html(htmlStuff);
								// 掛分頁按鈕
								pageNum = Math.ceil((segments.length)/10);
								let temp0 = "";
								let tempPageNum = (pageNum > 10)? 10 : pageNum;
								for(let i = 0; i < tempPageNum; i++){
									temp0 += "<button class='pageBtn' data-index='" + i + "' type='button' id='btnPage'>" + (i + 1) + "</button>&nbsp;&nbsp;&nbsp;";
								}
								pageHref.html(temp0);
								$('.pageBtn').on('click', function(){
									let pageIndex = $(this).attr('data-index');
									switchPage(pageIndex);
								})
							}

						}
					})
						
					// 【自訂函數 4】顯示資料庫最新100筆訂單 (SELECT TOP(100)) + 掛資料
					function showTop100() {
						let xhr = new XMLHttpRequest();
						let url = "<c:url value='/cart.controller/adminSelectTop100' />";
						xhr.open("GET", url, true);
						xhr.send();
						xhr.onreadystatechange = function() {
							if (xhr.readyState == 4 && xhr.status == 200) {
								parseSelectedRows(xhr.responseText);
								let htmlStuff = "";
								let tempCounter0 = (counter + 10 > segments.length)? segments.length : counter + 10;
								for(let i = counter; i < tempCounter0; i++){
									htmlStuff += segments[i]
								}
								dataArea.html(htmlStuff);
							}
						}
					} 

					// 【自訂函數 5】解析回傳資料&暫存進segments陣列
					function parseSelectedRows(map) {
						parsedMap = JSON.parse(map);
						let orders = parsedMap.list;
							let totalPrice = 0;
							rowNum = orders.length;
							segments = [];
							for (let i = 0; i < orders.length; i++) {
								totalPrice += orders[i].p_price;
								let temp0 =	 "<tr>" + 
													"<td><input name='ckbox' class='ckbox" + i + "' id='ckbox" + i + "' type='checkbox' value=' + " + i + "'><label for='ckbox" + i + "'></label></td>" +
													"<td><label data-val='" + orders[i].o_id + "' class='old" + i + "0' >" + orders[i].o_id + "</label></td>" +
													"<td><label data-val='" + orders[i].p_id + "' class='old" + i + "1' >" + orders[i].p_id + "</label></td>" +
													"<td><label data-val='" + orders[i].u_id + "' class='old" + i + "2' >" + orders[i].u_id + "</label></td>" +
													"<td><label data-val='" + orders[i].o_status + "' class='old" + i + "3' >" + orders[i].o_status + "</label></td>" +
													"<td><label data-val='" + orders[i].o_date + "' class='old" + i + "4' >" + orders[i].o_date + "</label></td>" +
													"<td><label data-val='" + orders[i].o_amt + "' class='old" + i + "5' id='num' >" + orders[i].o_amt + "</label></td>" +
													"<td width='120'><a href='http://localhost:8080/studiehub/cart.controller/cartAdminUpdate/" + orders[i].o_id + "'>修改</a></td>" +
													"</tr>";
								segments.push(temp0);
							}
					};

					// 【自訂函數 6】DELETE
					$('#delete').on('click', function(){
						let tempCounter1 = 0;
						let result = null;
						for(let i = 0; i < rowNum; i++) {
							let ckboxIsChecked = $('.ckbox' + i).is(':checked');
							tempCounter1 ++;
							
							if(ckboxIsChecked) { 
								let ckboxValue = $('.ckbox' + i).val();
								let o_id = $('.old' + i + '0').attr('data-val');
								
								let xhr = new XMLHttpRequest();
								xhr.open("POST", "<c:url value='/cart.controller/deleteAdmin' />", true);
								xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded"); // ❓
								xhr.send('o_id=' + o_id);
								xhr.onreadystatechange = function() {
									if (xhr.readyState == 4 && xhr.status == 200) {
										result = JSON.parse(xhr.responseText);
										console.log(result.state);
										// showTop100();
										if(tempCounter1 == rowNum){ // ❗
											pageHref.html("");
											dataArea.html("");
											mainFunc();
											// top.location = "http://localhost:8080/studiehub/cart.controller/cartAdminSelect"
											// if(result.status == "true"){
											// 	logo.text('已刪除勾選之項目！'); // ❗
											// } else {
											// 	logo.text('刪除未成功！');
											// }
										}
									}
								}
							}
						}
					})

					//【自訂函數 7】主程式函數
					function mainFunc(){
						console.log('Start of mainFunc()');
						headArea.html(
								"<th>DELETE BUTTON</th>"
								+ "<th>訂單代號(o_id)<br>(READ-ONLY)</th>"
								+ "<th>課程代號<br>(p_id)</th>"
								+ "<th>用戶帳號<br>(u_id)</th>"
								+ "<th>訂單狀態<br>(o_status)</th>"
								+ "<th>訂單時間<br>(o_date)</th>"
								+ "<th>訂單總額<br>(o_amt)</th>"
								+ "<th>操作</th>"
						)

						let xhr0 = new XMLHttpRequest();
						let url = "<c:url value='/cart.controller/adminSelectTop100' />";
						xhr0.open("GET", url, true);
						xhr0.send();
						xhr0.onreadystatechange = function() {
							if (xhr0.readyState == 4 && xhr0.status == 200) {
								// 解析&暫存回傳資料
								parseSelectedRows(xhr0.responseText);
								// 掛資料
								let htmlStuff = "";
								let tempCounter0 = (counter + 10 > segments.length)? segments.length : counter + 10;
								for(let i = counter; i < tempCounter0; i++){
									htmlStuff += segments[i]
								}
								dataArea.html(htmlStuff);
								// 掛分頁按鈕
								pageNum = Math.ceil((segments.length)/10);
								let temp0 = "";
								let tempPageNum = (pageNum > 10)? 10 : pageNum;
								for(let i = 0; i < tempPageNum; i++){
									temp0 += "<button class='pageBtn' data-index='" + i + "' type='button' id='btnPage'>" + (i + 1) + "</button>&nbsp;&nbsp;&nbsp;";
								}
								pageHref.html(temp0);
								$('.pageBtn').on('click', function(){
									let pageIndex = $(this).attr('data-index');
									switchPage(pageIndex);
								})
							}
						}
						console.log('End of mainFunc()');
					}
					
				/*********************************************************************************************************/
					// 主程式
					mainFunc();
					
 					

/* 
					$('input#num').on('focusout', function(){
						if(!isNaN($(this).val())){
							console.log('if')
							return;
						} else {
							console.log('else')
							logo.text('Only numbers are allowed.')
							$(this).val('')
						}
					})
	
	
					// func.04 
					
					$('i#gcIcon', 'button#gcBtn').on('click', function(event){
						event.preventDefault();
					})
	
					// func.05 刪除功能防呆 ❌施工中
					$('input#ckbox').on('click', function(){
						let ckboxes = $('input#ckbox:checked');
						$('#delete').attr('disabled', true);
							if($(ckboxes).length == 0 || $(ckboxes).length == null) {
								console.log('(if)' + $(ckboxes).length);
							} else {
								$('#delete').attr('disabled', false);
								console.log('(else)' + $(ckboxes).length);		
							}
					})
	 */
				})
				</script>		
		
		</body>
</html>