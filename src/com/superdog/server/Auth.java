package com.superdog.server;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;


import com.superdog.auth.*;

public class Auth extends HttpServlet {
	/**
	 * Constructor of the object.
	 */
	public Auth() {
		super();
	}

	/**
	 * Destruction of the servlet. <br>
	 */
	public void destroy() {
		super.destroy(); // Just puts "destroy" string in log
		// Put your code here
	}
	
	
	
	/**
	 * The doAuth method id called when the parameter is equal "Authentication"
	 */
	
	public String doAuth(HttpServletRequest request)
	throws IOException 
	{	
		HttpSession session = null;
		ServletContext sContext = null;
		int iVendorID = 0;
		int iDogID = 0;
		String sChallenge;
		String sResult;
		String sFactor;
		
		session = request.getSession(true);
		sContext = getServletContext();
		
		iVendorID = Integer.parseInt((String)sContext.getAttribute("VendorID"));
		iDogID = Integer.parseInt(request.getParameter("dogid"));
		sResult = request.getParameter("result");
		sFactor = (String)sContext.getAttribute("Factor");
		
		//Get challenge
		sChallenge = session.getAttribute("LoginChallenge").toString();
		
		//Set login session
		session.setAttribute("Login", "ON");
		int ret = Authentication.verifyDigest(iVendorID, iDogID, sChallenge, sResult, sFactor);
		if(ret == 0)
			return "[00" + ret + "]";
		else 
			return "["+ret+"]";
	}
	
	

	/**
	 * The doGet method of the servlet. <br>
	 * 
	 * This method is called when a form has its tag value method equals to get.
	 * 
	 * @param request
	 *            the request send by the client to the server
	 * @param response
	 *            the response send by the server to the client
	 * @throws IOException
	 */
	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws IOException {

		doPost(request, response);
	}

	/**
	 * The doPost method of the servlet. <br>
	 * 
	 * This method is called when a form has its tag value method equals to
	 * post.
	 * 
	 * @param request
	 *            the request send by the client to the server
	 * @param response
	 *            the response send by the server to the client
	 * @throws IOException
	 * @throws ServletException
	 *             if an error occurred
	 * @throws IOException
	 *             if an error occurred
	 */
	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws IOException {
		
		try {
			//Get challenge 
			if(request.getParameter("func").equals("getChallenge"))
			{	
				HttpSession session = request.getSession(true);
				String Challenge = Authentication.NewgenChallenge();
				//set session
				session.setAttribute("LoginChallenge", Challenge);
				response.getWriter().print("[" + Challenge + "]");
			}
			//Do authenticate
			else if(request.getParameter("func").equals("Authentication"))
			{
				String ret = doAuth(request);
				response.getWriter().print(ret);
			}
		} catch (UnsatisfiedLinkError e1) {
			e1.printStackTrace();
			response.getWriter().print("[001]");
		} catch (NoClassDefFoundError e1) {
			e1.printStackTrace();
			response.getWriter().print("[002]");
		} catch (Exception e) {
			e.printStackTrace();
			response.getWriter().print("[003]");
		}
	}

	/**
	 * Initialization of the servlet. <br>
	 * 
	 * @throws ServletException
	 *             if an error occurs
	 */
	public void init() throws ServletException {
		// Put your code here
	}
}
