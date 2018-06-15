<%@ page language="java" import="java.util.*,com.superdog.auth.*"
	pageEncoding="utf-8"%>

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
    //Callback function, if the dog has been removed the function will be called.
    function removeDog()
    {
	    reportStatus(7);
    }

    //Callback function, if the dog still exists the function will be called.
    function insertDog()
    {
	    window.location.href = "Login.jsp";
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
			//Open Dog
			stat = objAuth.Open(scope, authCode);
			if(0 != stat)
			{
				dogNotPresent = true;
				reportStatus(stat);
			}
			else
			{
				if (dogNotPresent == true)
				{
					dogNotPresent = false;
					window.location.href = "Login.jsp";
				}
			}
		}

        //Execute the check again after 2 seconds
        setTimeout(checkDog, 2000);
    }

    //Load callback functions, insertDog() and removeDog()
    function loadFunc()
    {	
	    var objAuth;
    	
	    //Get object
	    objAuth = getAuthObject();
    	
	    if (navigator.userAgent.indexOf("Window") > 0)
	    {
	        if (navigator.userAgent.indexOf("Chrome") > 0)  //Chrome
			{
				window.addEventListener("message", function (event) {
					if (event.source != window)
						return;
					if (event.data.type == "SNTL_FROM_HOST") {
						var ReturnText = event.data.text;
						if ("GetUserNameEx" == ReturnText.InvokeMethod) {
							if (0 == ReturnText.Status) {
								document.getElementById("username").value = ReturnText.UserNameStr;

								lastStatus = 0;
								if (dogNotPresent) {
									dogNotPresent = false;
									clearInfo();
								}
								return;
							}
							else {
								document.getElementById("username").value = "";
								reportStatus(parseInt(ReturnText.Status));
								lastStatus = ReturnText.Status;
								if (false == dogNotPresent) {
									dogNotPresent = true;
								}
								return;
							}
						}
						else if ("GetDigestEx" == ReturnText.InvokeMethod) {
							if (0 == ReturnText.Status) {
								var stat;
								var dogID;
								var digest;
								dogID = ReturnText.DogIdStr;
								digest = ReturnText.DigestStr;
								
								document.getElementById("dogid").value = dogID;
								document.getElementById("response").value = digest;
								
								stat = doAuth(dogID, digest);

								if (stat != 0) {
									reportStatus(stat);
									return;
								}
								else {
									document.forms["login"].submit();
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
			else if (window.ActiveXObject || "ActiveXObject" in window)  //IE
            {	
		        objAuth.SetCheckDogCallBack("insertDog", "removeDog");
	        }
	        else
            {  
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

    function validateLogin()
    {	
	    var challenge = "";
	    var stat = "";
	    var objAuth = "";
	    var dogID = "";
	    var digest = "";
	    var scope = "<dogscope/>";
	    var name = document.getElementById("username").value;
	    var pwd = document.getElementById("password").value;
    	
	    document.getElementById("password").value="";
    	
	    if(pwd.length<6 || pwd.length>16)
	    {
		    reportStatus(905);
		    return false;
	    }
    	
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
    	
	    //Get Object
	    objAuth = getAuthObject();
    	
	    //Get Auth Code
		if ("" == authCode) {
			authCode = getAuthCode();
		}
		
		if (navigator.userAgent.indexOf("Chrome") > 0) {  //Chrome
	
			//Get challenge string
			challenge = getChallenge();
			if(challenge.toString().length < 32)
			{
				if(challenge == "001")
				{
					reportStatus(916);
				}
				else if(challenge == "002")
				{
					reportStatus(917);
				}
				else
				{
					reportStatus(918);
				}
				return false;
			}
			
			//Generate digest
			objAuth.GetDigestEx(scope, authCode, pwd, challenge);
			return false;
		}
    	
	    //Open the dog
	    stat = objAuth.Open(scope, authCode);
	    if(stat != 0)
	    {
		    reportStatus(stat);
		    return false;
	    }
    	
	    //Verify the password
	    stat = objAuth.VerifyUserPin(pwd);
	    if(stat != 0)
	    {
		    objAuth.Close();
		    reportStatus(stat);
		    return false;
	    }
    	
	    //Get the DogID
	    stat = objAuth.GetDogID();
	    if(stat != 0)
	    {
		    objAuth.Close();
		    reportStatus(stat);
		    return false;
	    }

	    //Save the DogID
	    dogID = objAuth.DogIdStr;
	    document.getElementById("dogid").value = dogID;
     
        challenge = getChallenge();
	    if(challenge.toString().length < 32)
	    {
	        if(challenge == "001")
	        {
	            reportStatus(916);
	        }
	        else if(challenge == "002")
	        {
	            reportStatus(917);
	        }
	        else
	        {
	            reportStatus(918);
	        }
	        window.objAuth.Close();
	        return false;
	    }
    	
        //Generate digest
  	    stat = objAuth.GetDigest(challenge);
	    if(stat != 0)
	    {
		    objAuth.Close();
		    reportStatus(stat);
		    return false;
	    }
    	
	    digest = objAuth.DigestStr;
	    document.getElementById("response").value = digest;
    	
	    //Do authenticate
	    stat = doAuth(dogID, digest);
	    if(stat != 0)
	    {
		    objAuth.Close();
		    reportStatus(stat);
		    return false;
	    }
    	
	    objAuth.Close();
	    return true;
    }


</script>
	<body id="login" onload="loadFunc()">
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
			<form name="login" action="Main.jsp" method="get"
				onsubmit="return validateLogin()">
				<table cellpadding="15" border="0" align="center" style=""
					bgcolor="#d8f2ff">
					<caption style="">
						Login
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
							<input type="text" id="username" name="username" readonly
								size="32" maxlength="32" />
						</td>
					</tr>
					<tr>
						<td>
							Password
						</td>
						<td>
							<input type="password" id="password" name="password" size="32"
								maxlength="32" />
							<input type="hidden" id="dogid" name="dogid" />
							<input type="hidden" id="response" name="response" />
						</td>
					</tr>
					<tr>
						<td align="center" colspan="2">
							<p id="errorinfo" style="color: red" style="font-size=13"></p>
						</td>
					</tr>
					<tr align="center">
						<td align="center">
							<input  type="submit" value="Login">
						</td>
						<td>
							<a href="Register.jsp">Register</a>&nbsp;&nbsp;&nbsp;
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
		<script language="javascript">
		try
		{
			var stat = 0;
			var objAuth = "";
			var scope = "<dogscope/>";
			
			embedTag();
			
			// Get object
			objAuth = getAuthObject();
			
			// Get Auth Code
			if ("" == authCode) {
				authCode = getAuthCode();
			}
			
			if (navigator.userAgent.indexOf("Chrome") > 0) {  //Chrome
				objAuth.GetUserNameEx(scope, authCode);
			}
			else {
			
				// Open the dog
				stat = objAuth.Open(scope, authCode);
				if (stat != 0) {
					reportStatus(stat);
					throw ("Open Dog Error!");
				}

				// Get username from the dog
				stat = objAuth.GetUserName();
				if (stat != 0) {
					objAuth.Close();
					reportStatus(stat);
					throw ("Get Dog Username Error");
				}
				document.getElementById("username").value=objAuth.UserNameStr;
				objAuth.Close();
			}
		}
		catch(e)
		{
		}
		</script>
	</body>
</html>
