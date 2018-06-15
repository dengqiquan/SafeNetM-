package com.superdog.auth;

public class Authentication {
	
	public static int status;
	
	static
	{
		try
		{
			if( System.getProperty("sun.arch.data.model").equals("64"))
			{
				System.loadLibrary( "dog_auth_srv_x64" );
			}
			else
			{
				System.loadLibrary( "dog_auth_srv" );
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			try {
				throw e;
			} catch (Exception e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
	}
	
	public native static String getChallenge(int status[]);
	
	public native static int verifyDigest(int ivendorid, int idogid, String strchlge, String strrspn, String strfctr);
	
	public static String NewgenChallenge()
	{
		int[] dll_status = {0};
	    String s = null;
	    s = getChallenge(dll_status);
	    status = dll_status[0];
		return s;
	}
}
