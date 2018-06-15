<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>

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
	<SCRIPT LANGUAGE="JavaScript">

var dogNotPresent = false;
var lastStatus;
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
						dogNotPresent = false;
						lastStatus = 0;
						return;
					}
					else {                                
						lastStatus = ReturnText.Status;
						if (false == dogNotPresent) {
							dogNotPresent = true;
						}
					}
				}
				else if ("ChangeUserPinEx" == ReturnText.InvokeMethod) {
					if (0 == ReturnText.Status) {
						alert("Your password has been changed successfully!");
						window.location.href = "Login.jsp";
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

/**********************************************************************************************
Function: onOK
Parameters: none
Return: none
Description: Check input info modify the R/W info 
***********************************************************************************************/
function onOK()
{
	var result = false;
    var oldPwd = "";
    var newPwd = "";
    var stat = 0;
    var objAuth = "";
    var scope = "<dogscope/>";
    var cForm = window.document.ChangePinForm;
    if(window.ActiveXObject || "ActiveXObject" in window) //IE
	{
        //Add onfocus event
        var obj = document.getElementById("oldPwd");
        if (Object.hasOwnProperty.call(window, "ActiveXObject") && !window.ActiveXObject)
		{// is IE11  
			obj.addEventListener("onfocus", clearInfo, false);
		}
		else
		{
			obj.attachEvent("onfocus", clearInfo);  
		}
    }
    if(validateChangeForm())
    {
	    if(confirm("Do you really want to change the password?"))
        {
	        oldPwd = cForm.oldPwd.value;
	        newPwd = cForm.newPwd.value;
	        document.getElementById("oldPwd").value="";
	      
		    objAuth = getAuthObject();
		  
		    //Get Auth Code
			if ("" == authCode) {
				authCode = getAuthCode();
			}
			
			if (navigator.userAgent.indexOf("Chrome") > 0) //Chrome
			{
				if (dogNotPresent) {
					//return if dog not present
					reportStatus(parseInt(lastStatus));
					return false;
				}

				//Modify the pin
				objAuth.ChangeUserPinEx(scope, authCode, oldPwd, newPwd);
				window.document.forms.ChangePinForm.oldPwd.value = "";
				window.document.forms.ChangePinForm.newPwd.value = "";
				window.document.forms.ChangePinForm.retypePwd.value = "";
				return true;
			}
		    
	        //Open the SuperDog
	        stat = objAuth.Open(scope, authCode);
	        if(stat != 0)
	        {
			    reportStatus(stat);
			    return false;
	        }
	        
	        //Verify the pin
	        stat = objAuth.VerifyUserPin(oldPwd);
	        if(stat != 0)
	        {
			    reportStatus(stat);
			    return false;
	        }
	        
	        //Modify the pin
		    stat = objAuth.ChangeUserPin(newPwd)
	        if(stat == 0)
	        {
			    alert("Your password has been changed successfully!");
			    window.document.ChangePinForm.oldPwd.value ="";
			    window.document.ChangePinForm.newPwd.value ="";
			    window.document.ChangePinForm.retypePwd.value ="";
			    objAuth.Close();
			    window.location.href = "Login.jsp";
			    return true;
		    }
		    else
		    {
			    reportStatus(stat);
			    window.document.ChangePinForm.oldPwd.value ="";
			    window.document.ChangePinForm.newPwd.value ="";
			    window.document.ChangePinForm.retypePwd.value ="";
			    objAuth.Close();
			    return false;
		    }
        }     
    }
    else
    {
  	    window.document.ChangePinForm.oldPwd.value ="";
	    window.document.ChangePinForm.newPwd.value ="";
	    window.document.ChangePinForm.retypePwd.value ="";
        return false;
    }
}

</script>

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
			<form name=ChangePinForm method="post" action="">
				<table cellpadding="15" border="0" align="center" style=""
					bgcolor="#d8f2ff">
					<caption style="">
						Change Password
					</caption>
					<tr>
						<td height="15px">
						</td>
					</tr>
					<tr>
						<td>
							Current Password:
						</td>
						<td>
							<input type="password" id="oldPwd" size="32">
						</td>
					</tr>
					<tr>
						<td>
							New Password:
						</td>
						<td>
							<input type="password" id="newPwd" size="32">
						</td>
					</tr>
					<tr>
						<td>
							Confirm New Password:
						</td>
						<td>
							<input type="password" id="retypePwd" size="32">
						</td>
					</tr>
					<tr>
						<td align="center" colspan="2">
							<p id="errorinfo" style="color: red" style="font-size=13"></p>
						</td>
					</tr>
					<tr align="center">
						<td align="center">
							<input type="button" value="Change Password"
								onclick="return onOK()">
						</td>
						<td>
							<a href="Login.jsp">Login</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<a href="Register.jsp">Register</a>
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
