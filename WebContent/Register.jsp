<%@ page language="java" import="java.util.*,com.superdog.auth.*"
	pageEncoding="utf-8"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
	<head>
		<link href="styles1.css" type="text/css" media="screen"
			rel="stylesheet" />

		<object id="AuthIE" name="AuthIE" width="0px" height="0px"
			codebase="DogAuth.CAB#version=2,3,1,58083"
			classid="CLSID:05C384B0-F45D-46DB-9055-C72DC76176E3">
		</object>
		<script type="text/javascript" src="Func.js"></script>

		<script LANGUAGE="JavaScript">

var dogNotPresent = false;
var lastStatus;
var nameInDog = "";
var authCode = "";

function checkDog() {
	var scope = "<dogscope/>";	
	var objAuth = null;

	if ("" == authCode) {
		authCode = getAuthCode();
	}
	
	objAuth = getAuthObject();

	objAuth.GetUserNameEx(scope, authCode);

	//Execute the check again after 2 seconds
	setTimeout(checkDog, 2000);
}

function loadFunc() {
	if (navigator.userAgent.indexOf("Chrome") > 0) {
		window.addEventListener("message", function (event) {
			if (event.source != window)
				return;
			if (event.data.type == "SNTL_FROM_HOST") {
				var ReturnText = event.data.text;

				if ("GetUserNameEx" == ReturnText.InvokeMethod) {
					// return from GetUserNameEx
					if (0 == ReturnText.Status) {
						nameInDog = ReturnText.UserNameStr;
						dogNotPresent = false;
						lastStatus = 0;
						return;
					}
					else {
						nameInDog = "";
						lastStatus = ReturnText.Status;
						if (false == dogNotPresent) {
							dogNotPresent = true;
						}
					}
				}
				else if ("RegisterUserEx" == ReturnText.InvokeMethod) {
					// return from RegisterUserEx
					if (0 == ReturnText.Status) {
						document.RegisterForm.submit();
						alert("Register User Successful!");
						return;
					}
					else {
						reportStatus(parseInt(ReturnText.Status));
						alert("Register User Failed!");
						return;
					}
				}
				else if ("GetDigestEx" == ReturnText.InvokeMethod) {
					// return from GetDigestEx
					if (0 == ReturnText.Status) {
						var stat;
						var dogID;
						var digest;
						dogID = ReturnText.DogIdStr;
						digest = ReturnText.DigestStr;
						
						window.document.RegisterForm.dogid.value = dogID;
						window.document.RegisterForm.response.value = digest;

						stat = doAuth(dogID, digest);
						if (stat != 0) {
							reportStatus(stat);
							return;
						}
						else {
							var scope = "<dogscope/>";
							var objAuth = null;
							var userName = window.document.RegisterForm.username.value;
							var password = window.document.RegisterForm.password.value;

							if ("" == authCode) {
								authCode = getAuthCode();
							}
							
							objAuth = getAuthObject();
							
							objAuth.RegisterUserEx(scope, authCode, userName, password);
							return;
						}
						return;
					}
					else {
						reportStatus(parseInt(ReturnText.Status));
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

	embedTag();
}

//check the strings and record info into SuperDog
function onOK() {
    var challenge = "";    
    var oldPwd = "";
	var newPwd = "";
	var stat = 0;
	var objAuth = "";
	var dogID = "";
	var digest = "";
	var usrName = "";
	var scope = "<dogscope/>";
  
	if(window.ActiveXObject || "ActiveXObject" in window) //IE
	{
		//Add onfocus event
		var obj = document.getElementById("password");
		if (Object.hasOwnProperty.call(window, "ActiveXObject") && !window.ActiveXObject)
		{// is IE11  
			obj.addEventListener("onfocus", clearInfo, false);
		}
		else
		{
			obj.attachEvent("onfocus", clearInfo);  
		}
	}
	
	if(validateRegForm())
	{
		if(confirm("Do you really want to register?"))
    	{
			oldPwd = window.document.RegisterForm.password.value;
	      	newPwd = window.document.RegisterForm.repassword.value;
	      
	      	objAuth = getAuthObject();
	      	
			//Get Auth Code
		  	authCode = getAuthCode();
			
			if (navigator.userAgent.indexOf("Chrome") > 0) //Chrome
			{
				if (dogNotPresent) {
					//return if dog not present
					reportStatus(parseInt(lastStatus));
					window.document.RegisterForm.password.value="";
					window.document.RegisterForm.repassword.value="";
					window.document.RegisterForm.username.focus();
					return false;
				}
				
				if ("" != nameInDog) {
					window.document.RegisterForm.password.value="";
					window.document.RegisterForm.repassword.value="";
					window.document.RegisterForm.username.focus();
					reportStatus(915);
					return false;
				}
				
				//Get challenge string
				challenge = getChallenge();
				if(challenge.toString().length < 32)
				{
					if(challenge == "001")
					{
						reportStatus(916);
					}
					else if(challenge =="002")
					{
						reportStatus(917);
					}
					else
					{
						reportStatus(918);
					}
					objAuth.Close();
					return false;
				}
				
				//Generate digest
				objAuth.GetDigestEx(scope, authCode, "12345678", challenge);
				return true;
			}

	      	//Open the SuperDog
	      	stat = objAuth.Open(scope, authCode);
	      	if(stat != 0)
	      	{
				reportStatus(stat);
				window.document.RegisterForm.password.value="";
				window.document.RegisterForm.repassword.value="";
				window.document.RegisterForm.username.focus();
				return false;
	      	}
			// Get user name from the dog
			stat= objAuth.GetUserName();
			if(0 != stat)
			{
				objAuth.Close();
				reportStatus(stat); 
				return false;
			}
			usrName = objAuth.UserNameStr;
			if("" != usrName)
			{
				objAuth.Close();
				reportStatus(915);
				window.document.RegisterForm.password.value="";
				window.document.RegisterForm.repassword.value="";
				window.document.RegisterForm.username.focus();
				return false;
			}
	      	//Verify a new SuperDog necessarily
	      	stat = objAuth.VerifyUserPin("12345678");
		  	if(stat != 0)
		  	{
				objAuth.Close();
				window.document.RegisterForm.password.value="";
				window.document.RegisterForm.repassword.value="";
				window.document.RegisterForm.username.focus();
				reportStatus(stat);
				return false;
		  	}
		  	//Get DogID 
	      	stat = objAuth.GetDogID();
		  	if(stat != 0)
		  	{
				objAuth.Close();
				window.document.RegisterForm.password.value="";
				window.document.RegisterForm.repassword.value="";
				window.document.RegisterForm.username.focus();
				reportStatus(stat);
				return false;
		  	}
		  	
	      	dogID = objAuth.DogIdStr;
	      	window.document.RegisterForm.dogid.value = dogID;
	      	
			//Get challenge string
  		  	challenge = getChallenge();
	      	if(challenge.toString().length < 32)
	      	{
	      		if(challenge == "001")
	      		{
	      			reportStatus(916);
	      		}
	      		else if(challenge =="002")
	      		{
	      			reportStatus(917);
	      		}
	      		else
	      		{
	      			reportStatus(918);
	      		}
	      		objAuth.Close();
	      		return false;
	    	}
			
			//Generate digest
	      	stat = objAuth.GetDigest(challenge);
	      	if(stat != 0)
		  	{
				objAuth.Close();
				window.document.RegisterForm.password.value="";
				window.document.RegisterForm.repassword.value="";
				window.document.RegisterForm.username.focus();
				reportStatus(stat);
				return false;
	      	}
	      	
		  	digest = objAuth.DigestStr;
		  	window.document.RegisterForm.response.value = digest;
		  
          	//Do authenticate
          	stat = doAuth(dogID, digest);
          	if(stat != 0)
          	{
		      	objAuth.Close();
		      	reportStatus(stat);
		      	return false;
	      	}
		  
	      	objAuth.Close();
	      	//Submit the form
	      	document.RegisterForm.submit();
		  	return true;
    	}
    	return false;
  	}
  	else
  	{
  		window.document.RegisterForm.password.value="";
		window.document.RegisterForm.repassword.value="";
		window.document.RegisterForm.username.focus();
    	return false;
 	}
}

</script>
	</head>
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
		<div>
			<form name=RegisterForm method="post" action="Insert.jsp">
				<table cellpadding="15" border="0" align="center" style=""
					bgcolor="#d8f2ff">
					<caption style="">
						Register
					</caption>
					<tr>
						<td height="15px">
						</td>
					</tr>
					<tr>
						<td>
							Username
						</td>
						<td>
							<input type="text" id="username" name="username" size="32">
						</td>
					</tr>
					<tr>
						<td>
							Password
						</td>
						<td>
							<input type="password" id="password" name="password" size="32">
						</td>
					</tr>
					<tr>
						<td>
							Confirm Password
						</td>
						<td>
							<input type="password" id="repassword" size="32">
							<input type="hidden" id="dogid" name="dogid">
							<input type="hidden" id="response" name="response">
						</td>
					</tr>
					<tr>
						<td align="center" colspan="2">
							<p id="errorinfo" style="color: red" style="font-size=13"></p>
						</td>
					</tr>
					<tr align="center">
						<td align="center">
							<input type="button" value="Register" onclick="return onOK()">
						</td>
						<td>
							<a href="Login.jsp">Login</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<a href="ModifyPin.jsp">Change Password</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
		<div class="footer-bar">
			<div class="footer">
				Copyright 1983-2016 SafeNet, Inc. All rights reserved.
			</div>
		</div>
	</body>
</html>
