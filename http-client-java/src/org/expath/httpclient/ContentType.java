/****************************************************************************/
/*  File:       ContentType.java                                            */
/*  Author:     F. Georges - fgeorges.org                                   */
/*  Date:       2009-02-22                                                  */
/*  Tags:                                                                   */
/*      Copyright (c) 2009 Florent Georges (see end of file.)               */
/* ------------------------------------------------------------------------ */


package org.expath.httpclient;

import org.apache.http.Header;
import org.apache.http.HeaderElement;
import org.apache.http.NameValuePair;

/**
 * Represent a Content-Type header.
 *
 * Provide the ability to get the boundary param in case of a multipart
 * content type on the one hand, and the ability to get only the MIME type
 * string without any param on the other hand.
 *
 * @author Florent Georges
 * @date   2009-02-22
 */
public class ContentType
{
    public final static String CONTENT_TYPE_HEADER = "Content-Type";
    private final static String BOUNDARY = "boundary";
    
    private final Header myHeader;
    private final String myType;
    private final String myBoundary;
    
    public ContentType(final String type, final String boundary)
    {
        myHeader = null;
        myType = type;
        myBoundary = boundary;
    }

    public ContentType(final Header h)
            throws HttpClientException
    {
        if ( h == null ) {
            throw new HttpClientException("Header is null");
        }
        if ( ! CONTENT_TYPE_HEADER.equalsIgnoreCase(h.getName()) ) {
            throw new HttpClientException("Header is not content type");
        }
        myHeader = h;
        myType = HeaderSet.getHeaderWithoutParam(myHeader);
        String boundaryVal = null;
        final HeaderElement[] elems = h.getElements();
        if ( elems != null ) {
            for ( final HeaderElement e : elems ) {
                for ( final NameValuePair p : e.getParameters() ) {
                    if ( BOUNDARY.equals(p.getName()) ) {
                        boundaryVal = p.getValue();
                    }
                }
            }
        }
        
        myBoundary = boundaryVal;
    }

    @Override
    public String toString()
    {
        final String str;
        if ( myHeader == null ) {
            str = CONTENT_TYPE_HEADER + ": " + getValue();
        }
        else {
            str = myHeader.toString();
        }
        return str;
    }

    public String getType()
    {
        return myType;
    }

    public String getBoundary()
    {
        return myBoundary;
    }

    public String getValue()
    {
        // TODO: Why did I add the boundary before...?
//        if ( myHeader == null ) {
//            StringBuilder b = new StringBuilder();
//            b.append(myType);
//            if ( myBoundary != null ) {
//                b.append("; boundary=\"");
//                // TODO: Is that correct escaping sequence?
//                b.append(myBoundary.replace("\"", "\\\""));
//                b.append("\"");
//            }
//            return b.toString();
//        }
        String value = null;
        if ( myType != null ) {
            value = myType;
        } else if ( myHeader != null ) {
            value = myHeader.getValue();
        }
        return value;
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
