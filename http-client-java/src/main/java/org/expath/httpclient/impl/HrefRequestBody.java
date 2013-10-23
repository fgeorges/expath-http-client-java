/****************************************************************************/
/*  File:       HrefRequestBody.java                                        */
/*  Author:     F. Georges - fgeorges.org                                   */
/*  Date:       2009-02-25                                                  */
/*  Tags:                                                                   */
/*      Copyright (c) 2009 Florent Georges (see end of file.)               */
/* ------------------------------------------------------------------------ */


package org.expath.httpclient.impl;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URI;
import java.net.URISyntaxException;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.expath.httpclient.ContentType;
import org.expath.httpclient.HeaderSet;
import org.expath.httpclient.HttpClientException;
import org.expath.httpclient.HttpRequestBody;
import org.expath.httpclient.model.Element;

/**
 * TODO<doc>: ...
 *
 * @author Florent Georges
 * @date   2009-02-25
 */
public class HrefRequestBody
        extends HttpRequestBody
{
    
    private static final Log LOG = LogFactory.getLog(HrefRequestBody.class);
        
    private final static String SRC_ATTR = "src";
    
    private String myHref;
    
    /**
     * TODO: Check there is no other attributes (only @src and @media-type)...
     */
    public HrefRequestBody(final Element elem)
            throws HttpClientException
    {
        super(elem);
        myHref = elem.getAttribute(SRC_ATTR);
    }

    @Override
    public boolean isMultipart()
    {
        return false;
    }

    @Override
    public void setHeaders(final HeaderSet headers)
            throws HttpClientException
    {
        // set the Content-Type header (if not set by the user)
        if ( headers.getFirstHeader(ContentType.CONTENT_TYPE_HEADER) == null ) {
            headers.add(ContentType.CONTENT_TYPE_HEADER, getContentType());
        }
    }

    @Override
    public void serialize(final OutputStream out)
            throws HttpClientException
    {
        InputStream in = null;
        try {
            final String filename = new URI(myHref).getPath();
            in = new FileInputStream(new File(filename));
            final byte[] buf = new byte[4096];
            int l = -1;
            while((l = in.read(buf)) > 0) {
                out.write(buf, 0, l);
            }
        }
        catch ( final URISyntaxException ex ) {
            throw new HttpClientException("Bad URI: " + myHref, ex);
        }
        catch ( final FileNotFoundException ex ) {
            throw new HttpClientException("Error sending the file content", ex);
        }
        catch ( final IOException ex ) {
            throw new HttpClientException("Error sending the file content", ex);
        } finally {
            try {
                in.close();
            } catch(final IOException ioe) {
                LOG.warn(ioe.getMessage(), ioe);
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
