/****************************************************************************/
/*  File:       SinglePartRequestBody.java                                  */
/*  Author:     F. Georges - fgeorges.org                                   */
/*  Date:       2009-02-06                                                  */
/*  Tags:                                                                   */
/*      Copyright (c) 2009 Florent Georges (see end of file.)               */
/* ------------------------------------------------------------------------ */


package org.expath.httpclient.impl;

import java.io.OutputStream;
import java.util.Properties;
import javax.xml.transform.OutputKeys;
import net.iharder.Base64;
import org.expath.httpclient.ContentType;
import org.expath.httpclient.HeaderSet;
import org.expath.httpclient.HttpClientException;
import org.expath.httpclient.HttpRequestBody;
import org.expath.httpclient.SerializationParams;
import org.expath.httpclient.impl.BodyFactory.Type;
import org.expath.httpclient.model.Element;
import org.expath.httpclient.model.Sequence;

/**
 * TODO<doc>: ...
 *
 * @author Florent Georges
 * @date   2009-02-06
 */
public class SinglePartRequestBody
        extends HttpRequestBody
{
    
    private final Type myMethod;
    private final Sequence myChilds;
    private final SerializationParams mySerial = new SerializationParams();
    
    //
    // TODO: FIXME: Take serialization attributes into account!
    //
    public SinglePartRequestBody(final Element elem, final Sequence bodies, final Type method)
            throws HttpClientException
    {
        super(elem);
        myMethod = method;
        final String[] attr_names = {
            "src",
            "media-type",
            "method",
            "byte-order-mark",
            "cdata-section-elements",
            "doctype-public",
            "doctype-system",
            "encoding",
            "escape-uri-attributes",
            "indent",
            "normalization-form",
            "omit-xml-declaration",
            "standalone",
            "suppress-indentation",
            "undeclare-prefixes",
            "version"
        };
        mySerial.setEncoding(elem.getAttribute(attr_names[7]));
        mySerial.setIndent(parseYesNo(elem, attr_names[9]));
        mySerial.setOmitXmlDecl(parseYesNo(elem, attr_names[11]));
        // ...
        {
            // FIXME: For now, most of the attrs are not supported.  Throw an
            // error if any of them is there...
            final String[] NOT_SUPPORTED_ATTRS = {
                "byte-order-mark",
                "cdata-section-elements",
                "doctype-public",
                "doctype-system",
                "escape-uri-attributes",
                "normalization-form",
                "standalone",
                "suppress-indentation",
                "undeclare-prefixes",
                "version"
            };
            for ( int i = 0; i < NOT_SUPPORTED_ATTRS.length; ++i ) {
                final String name = NOT_SUPPORTED_ATTRS[i];
                final String val = elem.getAttribute(name);
                if ( val != null ) {
                    throw new HttpClientException("Attribute not supported yet: http:body/@" + name);
                }
            }
        }
        // check for not allowed attributes
        elem.noOtherNCNameAttribute(attr_names);
        // handle childs
        
        if(!getBodyElement().getContent().isEmpty()) {
            myChilds = getBodyElement().getContent();
        } else {
            // If there is no content in the http:body element, take the next item
            // in the $bodies parameter.
        
            final Sequence body = bodies.next();
            if ( body == null ) {
                throw new HttpClientException("There is not enough items within $bodies");
            }
            myChilds = body;
        }
    }

    private Boolean parseYesNo(final Element elem, final String attr_name)
            throws HttpClientException
    {
        final Boolean result;
        
        final String val = elem.getAttribute(attr_name);
        if ( val == null ) {
            result = null;
        }
        else if ( "yes".equals(val) ) {
            result = Boolean.TRUE;
        }
        else if ( "no".equals(val) ) {
            result = Boolean.FALSE;
        }
        else {
            final String msg = "Incorrect value for " + attr_name + ": " + val;
            throw new HttpClientException(msg);
        }
        
        return result;
    }

    @Override
    public void setHeaders(final HeaderSet headers)
            throws HttpClientException
    {
        // set the Content-Type header (if not set by the user)
        // TODO: "if not set by the user" -> really? To clarify within the spec.
        if ( headers.getFirstHeader("Content-Type") == null ) {
            String type = getContentType();
            // TODO: This has to be re-written when the @encoding serialization
            // param will be supported.
            if ( myMethod == Type.XML
                    || myMethod == Type.HTML
                    || myMethod == Type.XHTML
                    || myMethod == Type.TEXT ) {
                if ( mySerial.getEncoding() == null ) {
                    mySerial.setEncoding("UTF-8");
                }
                type += "; charset=" + mySerial.getEncoding();
            }
            else if ( mySerial.getEncoding() != null ) {
                throw new HttpClientException("Encoding is not allowed with method '" + myMethod + "'");
            }
            headers.add(ContentType.CONTENT_TYPE_HEADER, type);
        }
    }

    @Override
    public void serialize(OutputStream out)
            throws HttpClientException
    {
        // the default serialization options
        final Properties options = getSerializationParams();
        if ( myMethod == Type.HEX ) {
            // TODO: Add support for HEX (== "base16")
            // out = new Base16.OutputStream(out, Base16.DECODE);
            throw new HttpClientException("Method 'hex' not supported yet");
        }
        else if ( myMethod == Type.BINARY || myMethod == Type.BASE64 ) {
            out = new Base64.OutputStream(out, Base64.DECODE);
        }
        myChilds.serialize(out, options);
    }

    @Override
    public boolean isMultipart()
    {
        return false;
    }

    public Properties getSerializationParams()
            throws HttpClientException
    {
        final Properties props = new Properties();
        // method
        switch ( myMethod ) {
            case XML:
                props.put(OutputKeys.METHOD, "xml");
                break;
                
            case TEXT:
                props.put(OutputKeys.METHOD, "text");
                break;
                
            case HTML:
                props.put(OutputKeys.METHOD, "html");
                break;
                
            case XHTML:
                props.put(OutputKeys.METHOD, "xhtml");
                break;
                
            case BINARY:
            case BASE64:
                props.put(OutputKeys.METHOD, "expath:base64");
                break;
                
            case HEX:
                props.put(OutputKeys.METHOD, "expath:hex");
                break;
                
            default:
                throw new HttpClientException("Unsupported method! (yet): " + myMethod);
        }
        // encoding
        setOutputProperty(props, mySerial.getEncoding(), OutputKeys.ENCODING);
        // indent
        setYesNoOutputProperty(props, mySerial.getIndent(), OutputKeys.INDENT);
        // omit-xml-declaration
        setYesNoOutputProperty(props, mySerial.getOmitXmlDecl(), OutputKeys.OMIT_XML_DECLARATION);
        // TODO: Add support for other serialization parameters.
        // ...
        // return the properties
        return props;
    }

    private void setOutputProperty(final Properties props, final String value, final String key)
    {
        if ( value != null ) {
            props.setProperty(key, value);
        }
    }

    private void setYesNoOutputProperty(final Properties props, final Boolean value, final String key)
    {
        if ( value != null ) {
            props.setProperty(key, value ? "yes" : "no");
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
