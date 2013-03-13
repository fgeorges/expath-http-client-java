/****************************************************************************/
/*  File:       TextResponseBody.java                                       */
/*  Author:     F. Georges - fgeorges.org                                   */
/*  Date:       2009-02-02                                                  */
/*  Tags:                                                                   */
/*      Copyright (c) 2009 Florent Georges (see end of file.)               */
/* ------------------------------------------------------------------------ */


package org.expath.httpclient.impl;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.UnsupportedEncodingException;
import org.expath.httpclient.ContentType;
import org.expath.httpclient.HeaderSet;
import org.expath.httpclient.HttpClientException;
import org.expath.httpclient.HttpResponseBody;
import org.expath.httpclient.model.Result;
import org.expath.httpclient.model.TreeBuilder;

/**
 * TODO<doc>: ...
 *
 * @author Florent Georges
 * @date   2009-02-02
 */
public class TextResponseBody
        implements HttpResponseBody
{   
    private final static String BODY_ELEMENT = "body";
    private final static String MEDIA_TYPE_ATTR = "media-type";
    
    private ContentType myContentType;
    private HeaderSet myHeaders;
    
    public TextResponseBody(final Result result, final InputStream in, final ContentType type, final HeaderSet headers)
            throws HttpClientException
    {
        myContentType = type;
        myHeaders = headers;
        
        // FIXME: ...
        final String charset = "UTF-8";
        try {
            final Reader reader = new InputStreamReader(in, charset);
            result.add(reader);
        }
        catch (final UnsupportedEncodingException ex ) {
            final String msg = "not supported charset reading HTTP response: " + charset;
            throw new HttpClientException(msg, ex);
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
