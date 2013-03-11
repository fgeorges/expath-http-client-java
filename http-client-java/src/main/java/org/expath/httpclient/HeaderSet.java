/****************************************************************************/
/*  File:       HeaderHelper.java                                           */
/*  Author:     F. Georges - fgeorges.org                                   */
/*  Date:       2009-02-21                                                  */
/*  Tags:                                                                   */
/*      Copyright (c) 2009 Florent Georges (see end of file.)               */
/* ------------------------------------------------------------------------ */


package org.expath.httpclient;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import org.apache.http.Header;
import org.apache.http.HeaderElement;
import org.apache.http.message.BasicHeader;

/**
 * TODO<doc>: ...
 *
 * TODO: Change this class to a real wrapper around a {@link Header[]} or a
 * {@link Collection<Header>}.
 *
 * @author Florent Georges
 * @date   2009-02-21
 */
public class HeaderSet
        implements Iterable<Header>
{
    private final static String X_DUMMY = "X-Dummy";
    
    private final List<Header> myHeaders = new ArrayList<Header>();
    
    /**
     * Build a new object with no header.
     */
    public HeaderSet()
    {    
    }

    /**
     * Build a new object by *copying* its parameter.
     */
    public HeaderSet(final Header[] headers)
            throws HttpClientException
    {
        if ( headers == null ) {
            throw new HttpClientException("Headers array is null");
        }
        
        myHeaders.addAll(Arrays.asList(headers));
    }

    /**
     * Build a new object by *copying* its parameter.
     */
    public HeaderSet(final Collection<Header> headers)
            throws HttpClientException
    {
        if ( headers == null ) {
            throw new HttpClientException("Headers list is null");
        }
        headers.addAll(headers);
    }

    public Iterator<Header> iterator()
    {
        return myHeaders.iterator();
    }

    public Header[] toArray()
    {
        return myHeaders.toArray(new Header[0]);
    }

    public boolean isEmpty()
    {
        return myHeaders.isEmpty();
    }

    public Header add(final Header h)
    {
        myHeaders.add(h);
        return h;
    }

    public Header add(final String name, final String value)
    {
        final Header h = new BasicHeader(name, value);
        myHeaders.add(h);
        return h;
    }

    public Header getFirstHeader(final String name)
            throws HttpClientException
    {
        Header header = null;
        for ( final Header h : myHeaders ) {
            if ( name.equalsIgnoreCase(h.getName()) ) {
                header = h;
                break;
            }
        }
        return header;
    }

    public String getFirstHeaderWithoutParam(final String name)
            throws HttpClientException
    {
        final Header h = getFirstHeader(name);
        return getHeaderWithoutParam(h);
    }

    public static String getValueWithoutParam(final String header_value)
            throws HttpClientException
    {
        final Header h = new BasicHeader(X_DUMMY, header_value);
        return getHeaderWithoutParam(h);
    }

    public static String getHeaderWithoutParam(final Header header)
            throws HttpClientException
    {
        String result = null;
        
        // get the content type, only the mime string, like "type/subtype"
        if ( header != null ) {
            final HeaderElement[] elems = header.getElements();
            
            if(elems != null) {
                if ( elems.length == 1 ) {
                    result = elems[0].getName();
                } else {
                    throw new HttpClientException("Multiple Content-Type headers");
                }
            }
        }
        return result;
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
