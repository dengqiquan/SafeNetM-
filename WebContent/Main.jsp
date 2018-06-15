<%@ page language="java" import="java.util.*,java.sql.*,com.superdog.auth.*" pageEncoding="utf-8"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
	<head>
		<link href="styles1.css" type="text/css" media="screen"
			rel="stylesheet" />
	</head>
	<object id="AuthIE" name="AuthIE" width="0px" height="0px"
		codebase="DogAuth.CAB#version=2,3,1,58083"
		classid="CLSID:05C384B0-F45D-46DB-9055-C72DC76176E3">
	</object>
	<script type="text/javascript" src="Func.js"></script>
	<script language="javascript">

	var dogNotPresent = false;
	var authCode = "";

	function removeDog()
	{
		window.location.href = "Login.jsp";
	}

	function insertDog()
	{

	}
	
	function checkDog()
	{
		var stat = "";
		var scope = "<dogscope/>";

		//Get Auth Code
		if ("" == authCode) {
			authCode = getAuthCode();
		}

		//Get object
		objAuth = getAuthObject();

		if (navigator.userAgent.indexOf("Chrome") > 0) {
			objAuth.GetUserNameEx(scope, authCode);
		}
		else {
			//Open
			stat = objAuth.Open(scope, authCode);
			if (0 != stat) {
				window.location.href = "Login.jsp";
			}
		}

		//Execute the check again after 2 seconds
		setTimeout(checkDog, 2000);
	}

	function loadFunc()
	{
		var objAuth = "";

		embedTag();

		//Get object
		objAuth = getAuthObject();

		if (navigator.userAgent.indexOf("Window") > 0)
		{
			if (navigator.userAgent.indexOf("Chrome") > 0) { //Chrome
				window.addEventListener("message", function (event) {
					if (event.source != window)
						return;
					if (event.data.type == "SNTL_FROM_HOST") {
						var ReturnText = event.data.text;
						if ("GetUserNameEx" == ReturnText.InvokeMethod) {
							if (0 == ReturnText.Status) {
								dogNotPresent = false;
								return;
							}
							else {
								if (false == dogNotPresent) {
									dogNotPresent = true;
									if (undefined != typeof removeDog) {
										removeDog();
									}
								}
								return;
							}
						}
						else {
							return;
						}
					}
				}, false);
				
				setTimeout(checkDog, 1000);
			}
			else if (window.ActiveXObject || "ActiveXObject" in window) {  //IE
				objAuth.SetCheckDogCallBack("insertDog", "removeDog");
			}
			else { //FireFox  
				setTimeout(checkDog, 1000);
			}
		}
		else if (navigator.userAgent.indexOf("Mac") > 0)
		{
			setTimeout(checkDog, 1000);
		}
		else if (navigator.userAgent.indexOf("Linux") > 0)
		{
			setTimeout(checkDog, 1000);
		}
		else
		{
			;
		}
	}

  </script>
	<%
		String sUsername = null;
		String sDogID = null;
		String sResult = null;
		String sMessage = null;
		Connection conn = null;
		PreparedStatement st = null;
		ResultSet rs = null;
		String sUrl = null;
		try {
			sUsername = request.getParameter("username");
			sDogID = request.getParameter("dogid");
			sResult = request.getParameter("response");
			sMessage = null;

			request.getSession().setAttribute("username", sUsername);
			request.getSession().setAttribute("dogid", sDogID);
			
			if(!session.getAttribute("Login").equals("ON"))
			{
				response.sendRedirect("Login.jsp");
			}
			
			String sPath = this.getClass().getResource("/").getPath()
					.replaceAll("%20", " ");
			sPath = sPath.substring(1, sPath.length() - "classes/".length());

			Class.forName("sun.jdbc.odbc.JdbcOdbcDriver");
		
			if( System.getProperty("sun.arch.data.model").equals("64"))
			{
				sUrl = "jdbc:odbc:driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ="
					+ sPath + "UserDB.mdb";
			}
			else
			{
				sUrl = "jdbc:odbc:driver={Microsoft Access Driver (*.mdb)};DBQ="
					+ sPath + "UserDB.mdb";
			}

			conn = DriverManager.getConnection(sUrl);
			String sql = "select b.dog_id from userinfo a, doginfo b where a.user_id = b.user_id and b.dog_status=1 and b.dog_id=?";
			st = conn.prepareStatement(sql);
			st.setString(1, sDogID);
			rs = st.executeQuery();
			String sDBDogID = "";
			if (rs.next()) {
				sDBDogID = rs.getString("dog_id");
			}

			/*Verify DogID if needed */
			if (sDogID.equals(sDBDogID))
			{
				sMessage = "Welcome you " + sUsername + " !";
			}
			else
			{
				sMessage = "This SuperDog can't login! The user data is not on record in the Database";
			}
			
		} 
		catch (Exception e)
		{
			sMessage += e.toString();
		}
		finally 
		{
			try {
				if (rs != null)
				{
					rs.close();
				}
				if (st != null) 
				{
					st.close();
				}
				if(conn!=null) 
				{
					conn.close();
				}
			}
			catch (Exception e) 
			{
				sMessage += e.toString();
				e.printStackTrace();
			}
		}

	%>

	<body onload="loadFunc()">
		<div>
			<table width="100%" align="center" bgcolor="">
                <tr>
                    <td>
                        <img src="head.jpg" alt="head" />
                    </td>
                </tr>
                <tr height="50px">
                </tr>
            </table>
		</div>
		<p align="center"><%=sMessage%></p>
		<table align="center" border="1" bgcolor="#ffffff">
			<tr>
				<td>Username</td>
				<td>
					<%=request.getSession().getAttribute("username")%>
				</td>
			</tr>
			<tr>
				<td>
					DogID
				</td>
				<td>
					<%=request.getSession().getAttribute("dogid")%>
				</td>
			</tr>
			<tr>
				<td>
					Challenge
				</td>
				<td>
					<%=session.getAttribute("LoginChallenge")%>
				</td>
			</tr>
			<tr>
				<td>
					Response
				</td>
				<td>
					<%=sResult%>
				</td>
			</tr>
		</table>
		<div class="footer-bar">
			<div class="footer">
				Copyright 1983-2016 SafeNet, Inc. All rights reserved.
			</div>
		</div>
	</body>
</html>
