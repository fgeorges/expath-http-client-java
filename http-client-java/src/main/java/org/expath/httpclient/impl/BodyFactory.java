/****************************************************************************/
/*  File:       BodyFactory.java                                            */
/*  Author:     F. Georges - fgeorges.org                                   */
/*  Date:       2009-02-03                                                  */
/*  Tags:                                                                   */
/*      Copyright (c) 2009 Florent Georges (see end of file.)               */
/* ------------------------------------------------------------------------ */


package org.expath.httpclient.impl;

import java.io.InputStream;
import java.util.HashSet;
import java.util.Set;
import org.apache.http.Header;
import org.expath.httpclient.ContentType;
import org.expath.httpclient.HeaderSet;
import org.expath.httpclient.HttpClientException;
import org.expath.httpclient.HttpConnection;
import org.expath.httpclient.HttpRequestBody;
import org.expath.httpclient.HttpResponseBody;
import org.expath.httpclient.model.Element;
import org.expath.httpclient.model.Result;
import org.expath.httpclient.model.Sequence;


/**
 * Factory class for bodies, either in requests or in responses.
 *
 * @author Florent Georges
 * @date   2009-02-03
 */
public class BodyFactory
{
    /** Media types that must be treated as text types (in addition to text/*). */
    private final static Set<String> TEXT_TYPES = new HashSet<String>();
    static {
        TEXT_TYPES.add("application/x-www-form-urlencoded");
        TEXT_TYPES.add("application/xml-dtd");
    }

    /** Media types that must be treated as XML types (in addition to *+xml). */
    private final static Set<String> XML_TYPES = new HashSet<String>();
    static {
        // Doc: does not handle "application/xml-dtd" as XML
        // TODO: What about ".../xml-external-parsed-entity" ?
        XML_TYPES.add("text/xml");
        XML_TYPES.add("application/xml");
        XML_TYPES.add("text/xml-external-parsed-entity");
        XML_TYPES.add("application/xml-external-parsed-entity");
    }
    
    // TODO: Take new methods into account (XHTML, BASE64 and HEX).
    public static HttpRequestBody makeRequestBody(final Element elem, final Sequence bodies)
            throws HttpClientException
    {
        // method is got from @method if any...
        Type method = parseMethod(elem);
        // ...or from @media-type if no @method
        if ( method == null ) {
            method = parseType(elem);
        }
        
        final HttpRequestBody body;
        switch ( method ) {
            case MULTIPART:
                body = new MultipartRequestBody(elem, bodies);
                break;
            
            case SRC:
                body = new HrefRequestBody(elem);
                break;
                
            case XML:
            case HTML:
            case XHTML:
            case TEXT:
            case BINARY:
            case HEX:
            case BASE64:
                body = new SinglePartRequestBody(elem, bodies, method);
                break;
                
            default:
                throw new HttpClientException("could not happen");
        }
        return body;
    }

    public static HttpResponseBody makeResponseBody(final Result result, final ContentType type, final HttpConnection conn)
            throws HttpClientException
    {
        HttpResponseBody body = null;
        
        // it is legitimate to not have a body in a response; for instance
        // on a "304 Not Modified"
        if ( type != null && type.getType() != null) {
        
            final InputStream in = conn.getResponseStream();
            if ( in != null ) {
                if ( type.getType().startsWith("multipart/") ) {
                    body = new MultipartResponseBody(result, in, type, conn);
                }
                else {
                    body = makeResponsePart(result, null, in, type);
                }
            }
            
        }
        return body;
    }

    // package-level to be used within MultipartResponseBody ctor
    // TODO: Take new methods into account (XHTML, BASE64 and HEX).
    static HttpResponseBody makeResponsePart(final Result result, final HeaderSet headers, final InputStream in, final ContentType ctype)
            throws HttpClientException
    {
        final HttpResponseBody part;
        switch ( parseType(ctype) ) {
            case XML:
                // TODO: 'content_type' is the header Content-Type without any param
                // (i.e. "text/xml".)  Should we keep this, or put the whole header
                // (i.e. "text/xml; charset=utf-8")? (and for other types as well...)
                part = new XmlResponseBody(result, in, ctype, headers, false);
                break;
                
            case HTML:
                part = new XmlResponseBody(result, in, ctype, headers, true);
                break;
                
            case TEXT:
                part = new TextResponseBody(result, in, ctype, headers);
                break;
                        
            case BINARY:
                part = new BinaryResponseBody(result, in, ctype, headers);
                break;
                
            default:
                throw new HttpClientException("INTERNAL ERROR: cannot happen");
        }
        return part;
    }

    public static enum Type
    {
        XML,
        HTML,
        XHTML,
        TEXT,
        BINARY,
        BASE64,
        HEX,
        MULTIPART,
        SRC
    }

    /**
     * Decode the content type from a MIME type string.
     *
     * TODO: Take new methods into account (XHTML, BASE64 and HEX).
     */
    private static Type parseType(final String type)
    {
        final Type result;
        if ( type.startsWith("multipart/") ) {
            result = Type.MULTIPART;
        }
        else if ( "text/html".equals(type) ) {
            result = Type.HTML;
        }
        else if ( type.endsWith("+xml") || XML_TYPES.contains(type) ) {
            result = Type.XML;
        }
        else if ( type.startsWith("text/") || TEXT_TYPES.contains(type) ) {
            result = Type.TEXT;
        }
        else {
            result = Type.BINARY;
        }
        return result;
    }

    /**
     * Look for the header Content-Type in a header set and decode it.
     */
    public static Type parseType(final HeaderSet headers)
            throws HttpClientException
    {
        final Header h = headers.getFirstHeader(ContentType.CONTENT_TYPE_HEADER);
        if ( h == null ) {
            throw new HttpClientException("impossible to find the content type");
        }
        final ContentType ct = new ContentType(h);
        return parseType(ct);
    }

    /**
     * Decode the content type from a ContentType object.
     */
    public static Type parseType(final ContentType type)
            throws HttpClientException
    {
        if ( type == null ) {
            throw new HttpClientException("impossible to find the content type");
        }
        final String t = type.getType();
        if ( t == null ) {
            throw new HttpClientException("impossible to find the content type");
        }
        return parseType(t);
    }

    /**
     * Parse the @media-type from a http:body or http:multipart element.
     */
    private static Type parseType(final Element elem)
            throws HttpClientException
    {
        final Type result;
        final String local = elem.getLocalName();
        if ( "multipart".equals(local) ) {
            result = Type.MULTIPART;
        }
        else if ( ! "body".equals(local) ) {
            throw new HttpClientException("INTERNAL ERROR: cannot happen, checked before");
        }
        else {
            if ( elem.getAttribute("src") != null ) {
                result = Type.SRC;
            } else {
                final String content_type = elem.getAttribute("media-type");
                if ( content_type == null ) {
                    throw new HttpClientException("@media-type is not set on http:body");
                }
                final Type type = parseType(HeaderSet.getValueWithoutParam(content_type));
                if ( type == Type.MULTIPART ) {
                    String msg = "multipart type not allowed for http:body: " + content_type;
                    throw new HttpClientException(msg);
                }
                result = type;
            }
        }
        
        return result;
    }

    /**
     * Parse the @method from a http:body or http:multipart element.
     *
     * Return null if there is no @method.
     */
    private static Type parseMethod(final Element elem)
            throws HttpClientException
    {
        final String m = elem.getAttribute("method");
        final Type type;
        if(m == null) {
            type = null;
        } else {
            try {
                type = Type.valueOf(m.toUpperCase());
            } catch(final IllegalArgumentException iae) {
                throw new HttpClientException("Incorrect value for @method: " + m);
            }
        }
        return type;
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
