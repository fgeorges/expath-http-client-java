/****************************************************************************/
/*  File:       XmlResponseBody.java                                        */
/*  Author:     F. Georges - fgeorges.org                                   */
/*  Date:       2009-02-06                                                  */
/*  Tags:                                                                   */
/*      Copyright (c) 2009 Florent Georges (see end of file.)               */
/* ------------------------------------------------------------------------ */


package org.expath.httpclient.impl;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.UnsupportedEncodingException;
import javax.xml.transform.Source;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamSource;
import org.ccil.cowan.tagsoup.Parser;
import org.expath.httpclient.ContentType;
import org.expath.httpclient.HeaderSet;
import org.expath.httpclient.HttpClientException;
import org.expath.httpclient.HttpResponseBody;
import org.expath.httpclient.model.Result;
import org.expath.httpclient.model.TreeBuilder;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * TODO<doc>: ...
 *
 * @author Florent Georges
 * @date   2009-02-06
 */
public class XmlResponseBody
        implements HttpResponseBody
{
    private final static String BODY_ELEMENT = "body";
    private final static String MEDIA_TYPE_ATTR = "media-type";
    
    private ContentType myContentType;
    private HeaderSet myHeaders;
    
    public XmlResponseBody(final Result result, final InputStream in, final ContentType type, final HeaderSet headers, final boolean html)
            throws HttpClientException
    {
        // TODO: ...
        final String charset = "utf-8";
        try {
            final Reader reader = new InputStreamReader(in, charset);
            init(result, reader, type, headers, html);
        }
        catch ( final UnsupportedEncodingException ex ) {
            final String msg = "not supported charset reading HTTP response: " + charset;
            throw new HttpClientException(msg, ex);
        }
    }

    public XmlResponseBody(final Result result, final Reader in, final ContentType type, final HeaderSet headers, final boolean html)
            throws HttpClientException
    {
        init(result, in, type, headers, html);
    }

    private void init(final Result result, final Reader in, final ContentType type, final HeaderSet headers, final boolean html)
            throws HttpClientException
    {
        myContentType = type;
        myHeaders = headers;
        final String sys_id = "TODO-find-a-useful-systemId";
        try {
            final Source src;
            if ( html ) {
                final Parser parser = new Parser();
                parser.setFeature(Parser.namespacesFeature, true);
                parser.setFeature(Parser.namespacePrefixesFeature, true);
                final InputSource input = new InputSource(in);
                src = new SAXSource(parser, input);
                src.setSystemId(sys_id);
            }
            else {
                src = new StreamSource(in, sys_id);
            }
            result.add(src);
        }
        catch ( final SAXException ex ) {
            throw new HttpClientException("error parsing result HTML", ex);
        }
    }

    @Override
    public void outputBody(final TreeBuilder b)
            throws HttpClientException
    {
        if ( myHeaders != null ) {
            b.outputHeaders(myHeaders);
        }
        b.startElem(BODY_ELEMENT);
        b.attribute(MEDIA_TYPE_ATTR, myContentType.getValue());
        // TODO: Support other attributes as well?
        b.startContent();
        b.endElem();
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
