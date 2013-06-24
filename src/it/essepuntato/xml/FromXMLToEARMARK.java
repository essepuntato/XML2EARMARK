package it.essepuntato.xml;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.StringReader;
import java.net.URL;
import java.net.URLConnection;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

/**
 * Servlet implementation class FromXMLToEARMARK
 */
public class FromXMLToEARMARK extends HttpServlet {
	private static final long serialVersionUID = 1L;
    private String xsltURL = null;   
	
	
    /**
     * @see HttpServlet#HttpServlet()
     */
    public FromXMLToEARMARK() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
		response.setCharacterEncoding("UTF-8");
		
		try {
			String content = "";
			
			URL url = new URL(request.getParameter("url"));
			URLConnection connection = url.openConnection();
			
			BufferedReader in = new BufferedReader(
					new InputStreamReader(connection.getInputStream()));
		
			String line;
			while ((line = in.readLine()) != null) {
				content += line + "\n";
			}
			in.close();
			
			String result = getResult(content);
			
			response.setContentType("text/plain");
			PrintWriter out = response.getWriter();
			out.println(result);
			
		} catch (Exception e) {
			response.setContentType("text/html");
			PrintWriter out = response.getWriter();
			out.println(getErrorPage(e));
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
		response.setCharacterEncoding("UTF-8");
		
		try {
			
			String contentTest = new String(request.getParameter("content").getBytes(),"UTF-8");
			System.out.println("encoding request: " + request.getHeader("Content-type") + "\nstring: '" + 
					contentTest + "'\nlen: " + 
					contentTest.length() + "\nbyte: " + 
					contentTest.getBytes().length);
			
			
			String result = getResult(request.getParameter("content"));
			
			response.setContentType("text/plain");
			PrintWriter out = response.getWriter();
			out.println(result);
			
		} catch (Exception e) {
			response.setContentType("text/html");
			PrintWriter out = response.getWriter();
			out.println(getErrorPage(e));
		}
	}
	
	private String getResult(String content) throws TransformerException {
		resolvePaths();
		
		TransformerFactory tfactory = new net.sf.saxon.TransformerFactoryImpl();
		
		ByteArrayOutputStream output = new ByteArrayOutputStream();
		
		Transformer transformer =
			tfactory.newTransformer(
					new StreamSource(xsltURL));
		
		StreamSource inputSource = new StreamSource(new StringReader(content));
		
		transformer.transform(
				inputSource, 
				new StreamResult(output));
		
		return output.toString();
	}
	
	private String getErrorPage(Exception e) {
		return 
			"<html>" +
				"<head><title>XML2EARMARK error</title></head>" +
				"<body>" +
					"<h2>" +
					"XML2EARMARK error" +
					"</h2>" +
					"<p><strong>Reason: </strong>" +
					e.getMessage() +
					"</p>" +
				"</body>" +
			"</html>";
	}
	
	private void resolvePaths() {
		xsltURL = getServletContext().getRealPath("FromXMLToEARMARK.xsl");
	}

}
