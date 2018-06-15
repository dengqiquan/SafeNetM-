package com.superdog.server;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

public class ConfigInfo extends HttpServlet {

	/**
	 * Constructor of the object.
	 */
	public ConfigInfo() {
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
	 * The doGet method of the servlet. <br>
	 *
	 * This method is called when a form has its tag value method equals to get.
	 * 
	 * @param request the request send by the client to the server
	 * @param response the response send by the server to the client
	 * @throws ServletException if an error occurred
	 * @throws IOException if an error occurred
	 */
	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		doPost(request, response);
	}

	/**
	 * The doPost method of the servlet. <br>
	 *
	 * This method is called when a form has its tag value method equals to post.
	 * 
	 * @param request the request send by the client to the server
	 * @param response the response send by the server to the client
	 * @throws ServletException if an error occurred
	 * @throws IOException if an error occurred
	 */
	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		
		String sData = "";
		ServletContext sContext = getServletContext();
		if(request.getParameter("data").equals("AuthCode"))
		{
		    sData = (String)sContext.getAttribute("AuthCode");
		}
		else if(request.getParameter("data").equals("VendorID"))
		{
			sData = (String)sContext.getAttribute("VendorID");
		}
		else if(request.getParameter("data").equals("Factor"))
		{
			sData = (String)sContext.getAttribute("Factor");
		}
		else
		{
			sData = "[37515]";
		}
		response.setContentType("text/html");
		PrintWriter out = response.getWriter();
		out.print("["+sData+"]");
	}
	
	/**
	 * Get information from auth_code.xml  <br>
	 *
	 * @throws ServletException if an error occurs
	 */
	public void readAuthCode() throws ServletException {
		// Put your code here
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		try {
			DocumentBuilder db = dbf.newDocumentBuilder();
			ServletConfig  config = this.getServletConfig();
			String filename = config.getInitParameter("vmpath");
			if(filename == null)
			{	
				String realpath = this.getServletContext().getRealPath("");
				filename = realpath + "\\WEB-INF\\auth_code.xml";
				System.out.println("realpath="+filename);
			}
			else
			{
				filename = filename + "\\auth_code.xml";
			}
			//Open and parse the .xml
			File file = new File(filename);
			Document doc = db.parse(file);
			NodeList nl = doc.getElementsByTagName("dogauth");
			Element elAuth = (Element)nl.item(0);
			
			//Get the attribute of "vendor" element 
			Element elVendorID = (Element)elAuth.getElementsByTagName("vendor").item(0);
			String sID = elVendorID.getAttribute("id");
			
			//Get node value of "initdata"
			Node elData = elAuth.getElementsByTagName("authcode").item(0);
			String sData = elData.getFirstChild().getNodeValue();
			
			ServletContext sc = getServletContext();
			sc.setAttribute("VendorID", sID);
			sc.setAttribute("AuthCode", sData);
			
		} catch (ParserConfigurationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		catch (SAXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	
	/**
	 * Get information from auth_factor.xml  <br>
	 *
	 * @throws ServletException if an error occurs
	 */
	public void readAuthFactor() throws ServletException {
		// Put your code here
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		try {
			DocumentBuilder db = dbf.newDocumentBuilder();
			ServletConfig  config = this.getServletConfig();
			String filename = config.getInitParameter("vmpath");
			if(filename == null)
			{	
				String realpath = this.getServletContext().getRealPath("");
				filename = realpath+"\\WEB-INF\\auth_factor.xml";
				System.out.println("realpath="+filename);
			}
			else
			{
				filename = filename + "\\auth_factor.xml";
			}
			
			//Open and parse the .xml
			File file = new File(filename);
			Document doc = db.parse(file);
			NodeList nl = doc.getElementsByTagName("dogauth");
			Element elAuth = (Element)nl.item(0);
			
			//Get node value of "factor"
			String sFactor=null;
			Node elFactor = elAuth.getElementsByTagName("factor").item(0);
			if(elFactor == null)
			{
				sFactor="00000000";
			}
			else
			{
				sFactor = elFactor.getFirstChild().getNodeValue();
			}
			
			ServletContext sc = getServletContext();
			sc.setAttribute("Factor", sFactor);
			
		} catch (ParserConfigurationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		catch (SAXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	/**
	 * Initialization of the servlet. <br>
	 *
	 * @throws ServletException if an error occurs
	 */
	public void init() throws ServletException {
		// Put your code here
		
		// Read auth_code.xml file
		readAuthCode();
		
		// Read auth_factor.xml file
		readAuthFactor();
	}

}
