/****************************************************************************/
/*  File:       ApacheHttpConnection.java                                   */
/*  Author:     F. Georges - fgeorges.org                                   */
/*  Date:       2009-02-02                                                  */
/*  Tags:                                                                   */
/*      Copyright (c) 2009 Florent Georges (see end of file.)               */
/* ------------------------------------------------------------------------ */


package org.expath.httpclient.impl;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.ProxySelector;
import java.net.URI;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.HttpVersion;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.Credentials;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.CookieStore;
import org.apache.http.client.methods.HttpDelete;
import org.apache.http.client.methods.HttpEntityEnclosingRequestBase;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpHead;
import org.apache.http.client.methods.HttpOptions;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.client.methods.HttpRequestBase;
import org.apache.http.client.methods.HttpTrace;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.client.params.ClientPNames;
import org.apache.http.conn.routing.HttpRoutePlanner;
import org.apache.http.entity.ByteArrayEntity;
import org.apache.http.entity.ContentProducer;
import org.apache.http.entity.EntityTemplate;
import org.apache.http.impl.client.AbstractHttpClient;
import org.apache.http.impl.client.BasicCookieStore;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.conn.ProxySelectorRoutePlanner;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.expath.httpclient.HeaderSet;
import org.expath.httpclient.HttpClientException;
import org.expath.httpclient.HttpConnection;
import org.expath.httpclient.HttpConstants;
import org.expath.httpclient.HttpCredentials;
import org.expath.httpclient.HttpRequestBody;

/**
 * TODO<doc>: ...
 *
 * @author Florent Georges
 * @date   2009-02-02
 */
public class ApacheHttpConnection
        implements HttpConnection
{
    
    
    /**
     * The shared cookie store.
     *
     * TODO: Make it possible to serialize the cookies to disk?
     */
    private static final CookieStore COOKIES = new BasicCookieStore();
    /** The logger. */
    private static final Log LOG = LogFactory.getLog(ApacheHttpConnection.class);
    
    private static final String ONE_DOT_ZERO = "1.0";
    private static final String ONE_DOT_ONE = "1.1";
    private static final String HTTP_PROTOCOL_VERSION = "http.protocol.version";
    private static final String HTTP_SCHEME = "http";
    private static final String HTTPS_SCHEME = "https";
    
    
    /** The target URI. */
    private final URI myUri;
    /** The Apache request. */
    private HttpUriRequest myRequest;
    /** The Apache response. */
    private HttpResponse myResponse;
    /** The HTTP protocol version. */
    private HttpVersion myVersion;
    /** The Apache client. */
    private AbstractHttpClient myClient;
    /** Follow HTTP redirect? */
    private boolean myFollowRedirect = true;
    /** The timeout to use, in seconds, or null for default. */
    private Integer myTimeout = null;

    /**
     * The HTTP version (1.0 or 1.1) to use by default.
     * 
     * Configurable by the system property {@code org.expath.hc.http.version}.
     * By default, use HTTP 1.1.  Can be set on a per-request basis, by setting
     * the {@code http:request/@http} attribute.
     */
    private static HttpVersion DEFAULT_HTTP_VERSION = HttpVersion.HTTP_1_1;
    static {
        String ver = System.getProperty("org.expath.hc.http.version");
        if ( ver != null ) {
            ver = ver.trim();
            if ( ONE_DOT_ZERO.equals(ver) ) {
                DEFAULT_HTTP_VERSION = HttpVersion.HTTP_1_0;
            }
            else if ( ONE_DOT_ONE.equals(ver) ) {
                DEFAULT_HTTP_VERSION = HttpVersion.HTTP_1_1;
            }
            else {
                final String msg = "Wrong HTTP version: " + ver + " (check org.expath.hc.http.version)";
                throw new RuntimeException(msg);
            }
        }
    }
    
    /*
    private static final boolean[] METHOD_CHARS = new boolean[128];
    static {
        // SP = 32, HT = 9, so any char between 33 and 126 incl., minus
        // explicitly excluded chars...
        final String excl = "()<>@,;:\\\"/[]?={}";
        for ( char c = 0; c < 128; ++ c ) {
            if ( c < 33 || c == 127 ) {
                METHOD_CHARS[c] = false;
            }
            else if ( excl.indexOf(c) == -1 ) {
                METHOD_CHARS[c] = true;
            }
            else {
                METHOD_CHARS[c] = false;
            }
        }
    }*/
    
    public ApacheHttpConnection(final URI uri)
    {
        myUri = uri;
        myRequest = null;
        myResponse = null;
        myVersion = DEFAULT_HTTP_VERSION;
        myClient = null;
    }

    @Override
    public void connect(final HttpRequestBody body, final HttpCredentials cred)
            throws HttpClientException
    {
        if ( myRequest == null ) {
            throw new HttpClientException("setRequestMethod has not been called before");
        }
        try {
            // make a new client
            myClient = makeClient();
            // set the credentials (if any)
            setCredentials(cred);
            // set the request entity body (if any)
            setRequestEntity(body);
            // log the request headers?
            if ( LOG.isDebugEnabled() ) {
                LOG.debug("METHOD: " + myRequest.getMethod());
                final Header[] headers = myRequest.getAllHeaders();
                LoggerHelper.logHeaders(LOG, "REQ HEADERS", headers);
                LoggerHelper.logCookies(LOG, "COOKIES", COOKIES.getCookies());
            }
            // send the request
            myResponse = myClient.execute(myRequest);

            // TODO: Handle 'Connection' headers (for instance "Connection: close")
            // See for instance http://www.jmarshall.com/easy/http/.
            // ...

            // log the response headers?
            if ( LOG.isDebugEnabled() ) {
                final Header[] headers = myResponse.getAllHeaders();
                LoggerHelper.logHeaders(LOG, "RESP HEADERS", headers);
                LoggerHelper.logCookies(LOG, "COOKIES", COOKIES.getCookies());
            }
        }
        catch ( final IOException ex ) {
            throw new HttpClientException("Error executing the HTTP method: " + ex.getMessage(), ex);
        }
    }

    @Override
    public void disconnect()
    {
        if ( myClient != null ) {
            myClient.getConnectionManager().shutdown();
        }
    }

    @Override
    public void setHttpVersion(final String ver)
            throws HttpClientException
    {
        if ( myClient != null ) {
            final String msg = "Internal error, HTTP version cannot been "
                    + "set after connect() has been called.";
            throw new HttpClientException(msg);
        }
        if ( HttpConstants.HTTP_1_0.equals(ver) ) {
            myVersion = HttpVersion.HTTP_1_0;
        }
        else if ( HttpConstants.HTTP_1_1.equals(ver) ) {
            myVersion = HttpVersion.HTTP_1_1;
        }
        else {
            throw new HttpClientException("Internal error, unknown HTTP version: '" + ver + "'");
        }
    }

    @Override
    public void setRequestHeaders(final HeaderSet headers)
            throws HttpClientException
    {
        if ( myRequest == null ) {
            throw new HttpClientException("setRequestMethod has not been called before");
        }
        myRequest.setHeaders(headers.toArray());
    }
    
    @Override
    public void setRequestMethod(final String method, final boolean with_content)
            throws HttpClientException
    {
        if ( LOG.isInfoEnabled() )
        {
            LOG.debug("Request method: " + method + " (" + with_content + ")");
        }
        final String uri = myUri.toString();
        
        final ApacheHttp11Method m = ApacheHttp11Method.valueOf(method.toUpperCase());
        if ( m != null )
        {
            myRequest = m.getHttpUriRequest(uri);
        }
        else if ( with_content )
        {
            myRequest = new AnyEntityMethod(method, uri);
        }
        else
        {
            myRequest = new AnyEmptyMethod(method, uri);
        }
    }

    @Override
    public void setFollowRedirect(final boolean follow)
    {
        myFollowRedirect = follow;
    }

    @Override
    public void setTimeout(final int seconds)
    {
        myTimeout = seconds;
    }

    /**
     * Check the method name does match the HTTP/1.1 production rules.
     *
     *     Method         = "OPTIONS"                ; Section 9.2
     *                    | "GET"                    ; Section 9.3
     *                    | "HEAD"                   ; Section 9.4
     *                    | "POST"                   ; Section 9.5
     *                    | "PUT"                    ; Section 9.6
     *                    | "DELETE"                 ; Section 9.7
     *                    | "TRACE"                  ; Section 9.8
     *                    | "CONNECT"                ; Section 9.9
     *                    | extension-method
     *
     *     extension-method = token
     *
     *     token          = 1*&lt;any CHAR except CTLs or separators>
     *
     *     CHAR           = &lt;any US-ASCII character (octets 0 - 127)>
     *
     *     CTL            = &lt;any US-ASCII control character
     *                      (octets 0 - 31) and DEL (127)>
     *
     *     separators     = "(" | ")" | "&lt;" | ">" | "@"
     *                    | "," | ";" | ":" | "\" | <">
     *                    | "/" | "[" | "]" | "?" | "="
     *                    | "{" | "}" | SP | HT
     */
    /*
    private boolean checkMethodName(final String method)
    {
        for ( final char c : method.toCharArray() ) {
            if ( c > 127 || ! METHOD_CHARS[c] ) {
                return false;
            }
        }
        return true;
    }
    */

    @Override
    public int getResponseStatus()
    {
        return myResponse.getStatusLine().getStatusCode();
    }

    @Override
    public String getResponseMessage()
    {
        return myResponse.getStatusLine().getReasonPhrase();
    }

    @Override
    public HeaderSet getResponseHeaders()
            throws HttpClientException
    {
        return new HeaderSet(myResponse.getAllHeaders());
    }

    /**
     * TODO: How to use Apache HTTP Client facilities for response content
     * handling, instead of parsing this stream myself?
     */
    @Override
    public InputStream getResponseStream()
            throws HttpClientException
    {
        try {
            final HttpEntity entity = myResponse.getEntity();
            return entity == null ? null : entity.getContent();
        }
        catch ( final IOException ex ) {
            throw new HttpClientException("Error getting the HTTP response stream", ex);
        }
    }

    /**
     * Make a new Apache HTTP client, in order to serve this request.
     */
    private AbstractHttpClient makeClient()
    {
        final AbstractHttpClient client = new DefaultHttpClient();
        final HttpParams params = client.getParams();
        // use the default JVM proxy settings (http.proxyHost, etc.)
        final HttpRoutePlanner route = new ProxySelectorRoutePlanner(
                client.getConnectionManager().getSchemeRegistry(),
                ProxySelector.getDefault());
        client.setRoutePlanner(route);
        // do follow redirections?
        params.setBooleanParameter(ClientPNames.HANDLE_REDIRECTS, myFollowRedirect);
        // set the timeout if any
        if ( myTimeout != null ) {
            // See http://blog.jayway.com/2009/03/17/configuring-timeout-with-apache-httpclient-40/
            HttpConnectionParams.setConnectionTimeout(params, myTimeout * 1000);
            HttpConnectionParams.setSoTimeout(params, myTimeout * 1000);
        }
        // the shared cookie store
        client.setCookieStore(COOKIES);
        // the HTTP version (1.0 or 1.1)
        params.setParameter(HTTP_PROTOCOL_VERSION, myVersion);
        // return the just built client
        return client;
    }

    /**
     * Set the credentials on the client, based on the {@link HttpCredentials} object.
     */
    private void setCredentials(final HttpCredentials cred)
            throws HttpClientException
    {
        if ( cred == null ) {
            return;
        }
        final URI uri = myRequest.getURI();
        int port = uri.getPort();
        if ( port == -1 ) {
            final String scheme = uri.getScheme();
            if ( HTTP_SCHEME.equals(scheme) ) {
                port = 80;
            }
            else if ( HTTPS_SCHEME.equals(scheme) ) {
                port = 443;
            }
            else {
                throw new HttpClientException("Unknown scheme: " + uri);
            }
        }
        final String host = uri.getHost();
        final String user = cred.getUser();
        final String pwd = cred.getPwd();
        if ( LOG.isDebugEnabled() ) {
            LOG.debug("Set credentials for " + host + ":" + port
                    + " - " + user + " - ***");
        }
        final Credentials c = new UsernamePasswordCredentials(user, pwd);
        final AuthScope scope = new AuthScope(host, port);
        myClient.getCredentialsProvider().setCredentials(scope, c);
    }

    /**
     * Configure the request to get its entity body from the {@link HttpRequestBody}.
     */
    private void setRequestEntity(final HttpRequestBody body)
            throws HttpClientException
    {
        if ( body == null ) {
            return;
        }
        
        // make the entity from a new producer
        final HttpEntity entity;
        if ( myVersion == HttpVersion.HTTP_1_1 ) {
            // Take advantage of HTTP 1.1 chunked encoding to stream the
            // payload directly to the request.
            final ContentProducer producer = new RequestBodyProducer(body);
            final EntityTemplate template = new EntityTemplate(producer);
            template.setContentType(body.getContentType());
            entity = template;
        }
        else {
            // With HTTP 1.0, chunked encoding is not supported, so first
            // serialize into memory and use the resulting byte array as the
            // entity payload.
            final ByteArrayOutputStream buffer = new ByteArrayOutputStream();
            body.serialize(buffer);
            entity = new ByteArrayEntity(buffer.toByteArray());
        }
        // cast the request
        final HttpEntityEnclosingRequestBase req;
        if ( ! (myRequest instanceof HttpEntityEnclosingRequestBase) ) {
            final String msg = "Body not allowed on a " + myRequest.getMethod() + " request";
            throw new HttpClientException(msg);
        }
        else {
            req = (HttpEntityEnclosingRequestBase) myRequest;
        }
        // set the entity on the request
        req.setEntity(entity);
    }

    /**
     * A request entity producer, generating content from an {@link HttpRequestBody}.
     */
    private static class RequestBodyProducer
            implements ContentProducer
    {
        public RequestBodyProducer(final HttpRequestBody body)
        {
            myBody = body;
        }

        @Override
        public void writeTo(final OutputStream out)
                throws IOException
        {
            try {
                myBody.serialize(out);
            }
            catch ( final HttpClientException ex ) {
                throw new IOException("Error serializing the body content", ex);
            }
        }

        private HttpRequestBody myBody;
    }
    
    /**
     * Simple Interface to enable deferment of Apache HttpRequestBase object
     * construction, just used by the ApacheHttp11Method Enumeration
     */
    private interface HttpMethodForUri {
        public HttpRequestBase forUri(final URI uri);
    }
    
    /**
     * Simple Enumeration to wire HTTP Methods and URIs to
     * the corresponding Apache HttpRequestUri class
     * in a type-safe manner
     */
    private enum ApacheHttp11Method {
        DELETE(new HttpMethodForUri() {
            @Override
            public HttpRequestBase forUri(final URI uri) {
                return new HttpDelete(uri);
            }
        }),
        GET(new HttpMethodForUri() {
            @Override
            public HttpRequestBase forUri(final URI uri) {
                return new HttpGet(uri);
            }
        }),
        HEAD(new HttpMethodForUri() {
            @Override
            public HttpRequestBase forUri(final URI uri) {
                return new HttpHead(uri);
            }
        }),
        OPTIONS(new HttpMethodForUri() {
            @Override
            public HttpRequestBase forUri(final URI uri) {
                return new HttpOptions(uri);
            }
        }),
        POST(new HttpMethodForUri() {
            @Override
            public HttpRequestBase forUri(final URI uri) {
                return new HttpPost(uri);
            }
        }),
        PUT(new HttpMethodForUri() {
            @Override
            public HttpRequestBase forUri(final URI uri) {
                return new HttpPut(uri);
            }
        }),
        TRACE(new HttpMethodForUri() {
            @Override
            public HttpRequestBase forUri(final URI uri) {
                return new HttpTrace(uri);
            }
        });
        
        private final HttpMethodForUri httpMethodForUri;
        
        ApacheHttp11Method(final HttpMethodForUri httpMethodForUri) {
            this.httpMethodForUri = httpMethodForUri;
        }    
        
        /**
         * Gets an Apache HttpUriRequest for a URI for the HTTP Method of the 
         * Enumeration constant
         *
         * @param uri The URI for the HTTP Request
         * @return HttpUriRequest for the URI and Method
         */
        public HttpUriRequest getHttpUriRequest(final String uri) {
            return httpMethodForUri.forUri(URI.create(uri));
        }
        
        /**
         * Just like Enum.valueOf but instead of throwing
         * IllegalArgumentException if there is no enum constant, we return null
         * instead
         * 
         * @param The name of a constant in the Enumeration
         * @return The Enumeration Constant
         */
        public static ApacheHttp11Method valueOfOrNull(final String name) {
            try {
                return valueOf(name.toUpperCase());
            } catch(final IllegalArgumentException iae) {
                return null;
            }
        } 
    }
}


/* ------------------------------------------------------------------------ */
/*  DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS COMMENT.               */
/*                                                                          */
/*  The contents of this file are subject to the Mozilla Public License     */
/*  Version 1.0 (the "License"); you may not use this file except in        */
/*  compliance with the License. You may obtain a copy of the License at    */
/*  http://www.mozilla.org/MPL/.                                            */
/*                                                                          */
/*  Software distributed under the License is distributed on an "AS IS"     */
/*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied.  See    */
/*  the License for the specific language governing rights and limitations  */
/*  under the License.                                                      */
/*                                                                          */
/*  The Original Code is: all this file.                                    */
/*                                                                          */
/*  The Initial Developer of the Original Code is Florent Georges.          */
/*                                                                          */
/*  Contributor(s): Adam Retter                                             */
/* ------------------------------------------------------------------------ */
