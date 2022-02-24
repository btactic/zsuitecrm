<%
/*
 *	------ Zimbra - Sugar Zimblet Java Proxy ------
 *	----- Author: Irontec -- Date: 27/12/2010 -----
 *
 *	This JSP works as proxy for JSON petitions bettween Zsugar zimlet and Sugar REST api.
 *	It includes task done in server side, such as attachment handle.
 */
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" import="java.net.*,java.io.*,java.util.*,java.text.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" import="org.apache.http.client.*,org.apache.http.impl.client.*,org.apache.http.client.utils.*,org.apache.http.client.methods.HttpGet,org.apache.http.client.config.*,org.apache.http.HttpResponse,org.apache.http.client.methods.HttpPost,org.apache.http.entity.mime.MultipartEntityBuilder,org.apache.http.HttpEntity,org.apache.http.HttpStatus,org.apache.http.NameValuePair,org.apache.http.message.BasicNameValuePair,org.apache.http.client.entity.UrlEncodedFormEntity,java.nio.charset.Charset" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" import="org.apache.commons.fileupload.*,org.apache.commons.fileupload.disk.*, org.apache.commons.io.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" import="biz.source_code.base64Coder.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" import="javax.net.ssl.HttpsURLConnection, javax.net.ssl.SSLContext, javax.net.ssl.TrustManager, javax.net.ssl.X509TrustManager" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" import="com.zimbra.common.util.*" %>

<%
	// Get Post data
	String input_type       = request.getParameter("input_type");
        String method           = request.getParameter("method");
        String response_type    = request.getParameter("response_type");
        String rest_data        = request.getParameter("rest_data");
        String sugar_url        = request.getParameter("sugar_url");
        String encoding 	= request.getCharacterEncoding();
        if (encoding == null) encoding = "UTF-8";

	// Special Treatment for set_note_attachment REST method
	if ( method.equals("set_note_attachment")){
		// Parse attachment URL
                int beg = rest_data.indexOf("file\":");
                int end = rest_data.indexOf("related_module_id\":");
		String attUrl = rest_data.substring(beg+7,end-3);
		String prefix = rest_data.substring(0,beg+7);
		String sufix  = rest_data.substring(end-3);

          try
          {
		// Download the file to the local temporary path
		String dirPath = System.getProperty("java.io.tmpdir", "/tmp");
		String filePath = dirPath + "/zsugar_att_" + System.currentTimeMillis();
		File readFile = new File (filePath);
		FileOutputStream readFileStream = new FileOutputStream(readFile.getPath());
		
		// Get Post Cookies
		javax.servlet.http.Cookie reqCookie[] = request.getCookies();
		org.apache.http.impl.client.BasicCookieStore cookieStore = new org.apache.http.impl.client.BasicCookieStore ();
		org.apache.http.impl.cookie.BasicClientCookie[] clientCookie = new org.apache.http.impl.cookie.BasicClientCookie[reqCookie.length];
		String hostName = request.getServerName () + ":" + request.getServerPort();
	
		for (int i=0; i<reqCookie.length; i++) {
		        javax.servlet.http.Cookie cookie = reqCookie[i];
		        clientCookie[i] = new org.apache.http.impl.cookie.BasicClientCookie (cookie.getName(), cookie.getValue());
		        clientCookie[i].setDomain (hostName);
		        clientCookie[i].setPath ("/");
		        // TODO: Cookie never expires
		        clientCookie[i].setSecure(false);
		        cookieStore.addCookie(clientCookie[i]);
    		}

		// Create a HTTP client with the actual state 
		RequestConfig requestConfig = RequestConfig.custom()
         .setConnectionRequestTimeout(10000)
         .setConnectTimeout(10000)
         .setSocketTimeout(10000)
         .build();
		HttpClientBuilder tmpHttpClientBuilder = HttpClientBuilder.create();
		tmpHttpClientBuilder.setDefaultCookieStore(cookieStore);
		tmpHttpClientBuilder.setDefaultRequestConfig(requestConfig);
		HttpClient srcClient = tmpHttpClientBuilder.build();

		// Convert the URL
		int paramsbeg = attUrl.indexOf("id=")-1;
		String filename = attUrl.substring(0, paramsbeg);
		String getparam = attUrl.substring(paramsbeg, attUrl.length());
		String decodedURL = URLDecoder.decode(filename, "UTF-8");
		URL url = new URL(decodedURL);
		URI uri = new URI(url.getProtocol(), url.getUserInfo(), url.getHost(), url.getPort(), url.getPath(), url.getQuery(), url.getRef());
		attUrl = uri.toURL().toString() + getparam;
		//out.println(attUrl);

		// Download the Image
		HttpGet get = new HttpGet (attUrl);
		Enumeration headerNamesImg = request.getHeaderNames();
			while(headerNamesImg.hasMoreElements()) {
				String headerNameImg = (String)headerNamesImg.nextElement();
				get.setHeader(headerNameImg, request.getHeader(headerNameImg));
		}
		HttpResponse httpResponse = srcClient.execute(get);
		// TODO: Improve status handling
		// int statusCode = httpResponse.getStatusLine().getStatusCode();
		// if (statusCode == HttpStatus.SC_OK) {

		// Copy the image to a local temporary file
		ByteUtil.copy(httpResponse.getEntity().getContent(), false, readFileStream, false);
		readFileStream.close();

		// Read the temporary file and output its Base64-values
		BufferedInputStream base64In = new BufferedInputStream(new FileInputStream(readFile.getPath()));

		int lineLength = 12288;
		byte[] buf = new byte[lineLength/4*3];

	
		while(true) {
		      int len = base64In.read(buf);
		      if (len <= 0) break;
		      prefix += new String(Base64Coder.encode(buf, 0, len));
		}
		base64In.close();
		
		// Update prameter rest_data with the binary data of the file
		rest_data = prefix + sufix;

	  } catch (Exception e) { 
		out.println("A problem occurried while handling attachment file:"+e.getMessage());
	  }
 	}



      // Create a HTTP client to foward REST petition
	  HttpClientBuilder tmpHttpClientBuilder2 = HttpClientBuilder.create();
	  HttpClient client = tmpHttpClientBuilder2.build();

      BufferedReader br = null;

      // Set the input data for POST method
      HttpPost pmethod = new HttpPost(sugar_url);
      Enumeration headerNames = request.getHeaderNames();
      while(headerNames.hasMoreElements()) {
		String headerName = (String)headerNames.nextElement();
		// Do not set Content-Length header again
		// Do not overwrite host with original Zimbra host
		if ( ( headerName == "Content-Length" ) || ( headerName == "Host" ) ) {
		// DO NOTHING
		} else {
				pmethod.setHeader(headerName, request.getHeader(headerName));
		}
      }

    List<NameValuePair> params = new ArrayList<NameValuePair>();
    params.add(new BasicNameValuePair("input_type", input_type));
    params.add(new BasicNameValuePair("method", method));
    params.add(new BasicNameValuePair("response_type", response_type));
    params.add(new BasicNameValuePair("rest_data", rest_data));
    pmethod.setEntity(new UrlEncodedFormEntity(params,encoding));

      try{
        HttpResponse httpResponse2 = client.execute(pmethod);
		int returnCode = httpResponse2.getStatusLine().getStatusCode();

        if(returnCode == HttpStatus.SC_NOT_IMPLEMENTED) {
                out.println("The Post method is not implemented by this URI");
                // still consume the response body
                br = new BufferedReader(new InputStreamReader(httpResponse2.getEntity().getContent()));
                String readLine;
                while(((readLine = br.readLine()) != null)) {
                    // DO NOTHING
                }
        } else {
                br = new BufferedReader(new InputStreamReader(httpResponse2.getEntity().getContent()));
                String readLine;
                // Write the response body
                while(((readLine = br.readLine()) != null)) {
                    out.println(readLine); 
                }
        }

      } catch (Exception e) {
		out.println(e);
      } finally {
        pmethod.releaseConnection();
        if(br != null) try { br.close(); } catch (Exception fe) {}
     }

%>
	

