<%@ page language="java" import="java.util.*,java.sql.*,com.superdog.auth.*" pageEncoding="utf-8"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
	<head>
		<object id="AuthIE" name="AuthIE" width="0px" height="0px"
			codebase="DogAuth.CAB#version=2,3,1,58083"
			classid="CLSID:05C384B0-F45D-46DB-9055-C72DC76176E3">
		</object>

	</head>
	<script type="text/javascript" src="Func.js"></script>

	<body>
	</body>
	<%
		String sUsername = null;
		String sDogID = null;
		String sUserPassword = null;
		String sUserID = null;
	    Connection conn = null;
	    PreparedStatement st = null;
	    ResultSet rs = null;
	    PreparedStatement st1 = null;
	    PreparedStatement st2 = null;
	    ResultSet rs2 = null;
	    PreparedStatement st3 = null;
	    String url = null;

		try {
			sUsername = request.getParameter("username");
			sDogID = request.getParameter("dogid");
			sUserPassword = request.getParameter("password");
			
			//Check the request wheather it has passed the authentication
			if(!session.getAttribute("Login").equals("ON"))
			{
				response.sendRedirect("Login.jsp");
			}
			
			String sPath = this.getClass().getResource("/").getPath().replaceAll("%20", " ");
			sPath = sPath.substring(1, sPath.length() - "classes/".length());
			Class.forName("sun.jdbc.odbc.JdbcOdbcDriver");
			
			if( System.getProperty("sun.arch.data.model").equals("64"))
			{
				
				url = "jdbc:odbc:driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ="
					+ sPath + "UserDB.mdb";
			}
			else
			{
				url = "jdbc:odbc:driver={Microsoft Access Driver (*.mdb)};DBQ="
					+ sPath + "UserDB.mdb";
			}
			
			conn = DriverManager.getConnection(url);
			conn.setAutoCommit(false);

			//Check database whether the SuperDog has been registered
			String sql = "select count(*)from userinfo a, doginfo b where a.user_id=b.user_id and b.dog_id=? and b.dog_status=1";
			st = conn.prepareStatement(sql);
			st.setString(1, sDogID);
			rs = st.executeQuery();
			String DogID = "";
			if (rs.next()) {
				DogID = rs.getString("expr1000");
				if (DogID.equals("1")) {
	%>
	<script type="text/javascript">
				alert("The SuperDog has been registered!");
		</script>
	<%
		} else {
					//Record the user info into database
					sql = "insert into userinfo(user_name, dog_id) values(?,?)";
					st1 = conn.prepareStatement(sql);
					st1.setString(1, sUsername);
					st1.setString(2, sDogID);
					int row = st1.executeUpdate();
					if (row > 0) {
						//Get autonumber
						sql = "SELECT @@IDENTITY";
						st2 = conn.prepareStatement(sql);
						rs2 = st2.executeQuery();
						if (rs2.next()) {
							//Record the dog info into database.
							sUserID = rs2.getString("expr1000");
							sql = "insert into doginfo(user_id, dog_id) values(?,?)";
							st3 = conn.prepareStatement(sql);
							st3.setString(1, sUserID);
							st3.setString(2, sDogID);
							row = st3.executeUpdate();
							if (row > 0) {
	%>
	<script type="text/javascript">
			
			var objAuth = "";
			var authCode = "";
			var scope = "<dogscope/>";
			
			embedTag();
			//Get object
			objAuth = getAuthObject();
			
			//Get AuthCode
			authCode = getAuthCode();
			
			var stat = objAuth.Open(scope, authCode);
			if(stat != 0)
			{
				alert("Open Failed!");
			}
			//Record the registration info into the SuperDog
			stat = objAuth.RegisterUser('<%=sUsername%>', '<%=sUserPassword%>');
			if(stat != 0)
			{
				alert("Register User Failed!");
			}
			else
			{
				alert("Register User Successful!");
			}
			objAuth.Close();
	</script>
	<%
		conn.commit();
							} else {
								conn.rollback();
							}
						} else {
							conn.rollback();
						}
					} else {
						conn.rollback();
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			%>
            <script type="text/javascript">
				alert("Insert failed : "+"<%=e.toString()%>");
			</script>
	        <%
		}
		finally
		{
            try 
            { 
                 if (st3 != null)
                 {
					 st3.close();
				 } 
			     if (rs2 != null) {
					 rs2.close();
			     }
			     if (st2 != null) {
					 st2.close();
			     }
			     if (st1 != null) {
					 st1.close();
			     }
			     if (rs != null) {
					 rs.close();
			     }
			     if (st != null) {
					 st.close();
			     }
			     if (conn != null) 
                 {
                     conn.close();
                 } 
             } 
             catch (Exception e) 
             {
                 e.printStackTrace();
             }
             %>
             <script type="text/javascript">
				 window.location.href = "Login.jsp";
			 </script>
	         <%
        }
	%>
</html>
