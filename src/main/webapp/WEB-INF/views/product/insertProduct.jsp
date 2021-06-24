<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
<link rel='stylesheet' href="${pageContext.request.contextPath}/assets/css/main.css">
<title>Studie Hub</title>

<script>
var u_id = "${loginBean.u_id}";

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
    var logoutHref = document.getElementById('logoutHref');
    if(u_id){
    	loginHref.hidden = true;
    	logoutHref.style.visibility = "visible";	//有登入才會show登出標籤(預設為hidden)
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

							<form:form method="POST" modelAttribute="productInfo" enctype='multipart/form-data'>
								<table border="1">
                                    <tr>
                                        <td>課程名稱:</td>
                                        <td><form:input path="p_Name"/></td>
                                    </tr>
                                    <tr>
                                        <td>課程類別:</td>
                                        <td><form:select path="p_Class">
                                        		<form:option label="請挑選" value="-1"/>
                                        		<form:option label="英文" value="en"/>
                                        		<form:option label="日文" value="ja"/>
                                        	</form:select></td>
                                    </tr>
                                    <tr>
                                        <td>課程價錢</td>
                                        <td><form:input path="p_Price"/></td>
                                    </tr>
                                    <tr>
                                        <td>課程介紹:</td>
                                    	<td><form:textarea path="p_DESC"/></td>
                                    </tr>
                                    <tr>
                                    	<td>課程圖片:</td>
                                        <td><form:input path="p_Img" type="file" /></td>
                                    </tr>
                                    <tr>
                                    	<td>課程影片:</td>
                                        <td><form:input path="p_Video" type="file" /></td>
                                    </tr>
                                    <tr>
                                    <td><input type="submit"></td>
                                    </tr>
                                </table>
							</form:form>

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

	</body>
</html>