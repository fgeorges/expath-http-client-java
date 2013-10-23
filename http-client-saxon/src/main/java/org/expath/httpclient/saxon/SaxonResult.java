/****************************************************************************/
/*  File:       SaxonResult.java                                            */
/*  Author:     F. Georges - H2O Consulting                                 */
/*  Date:       2011-03-10                                                  */
/*  Tags:                                                                   */
/*      Copyright (c) 2011 Florent Georges (see end of file.)               */
/* ------------------------------------------------------------------------ */


package org.expath.httpclient.saxon;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;
import java.util.ArrayList;
import java.util.List;
import javax.xml.transform.Source;
import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.om.Item;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.ArrayIterator;
import net.sf.saxon.value.Base64BinaryValue;
import net.sf.saxon.value.StringValue;
import org.expath.httpclient.HttpClientException;
import org.expath.httpclient.HttpResponse;
import org.expath.httpclient.model.Result;

/**
 * Implementation of {@link Item} for Saxon.
 *
 * @author Florent Georges
 * @date   2011-03-10
 */
public class SaxonResult
        implements Result
{
    public SaxonResult(XPathContext ctxt, String ns)
    {
        myItems = new ArrayList<Item>();
        myCtxt = ctxt;
        myNs = ns;
    }

    @Override
    public void add(final Reader reader)
            throws HttpClientException
    {
        final StringBuilder builder = new StringBuilder();
        final char[] buf = new char[4096];
        int read = -1;
        try
        {
            while((read = reader.read(buf)) > -1)
            {
                builder.append(buf, 0, read);
            }
            
            final Item item = new StringValue(builder.toString());
            myItems.add(item);
        }
        catch(final IOException ioe)
        {
            throw new HttpClientException(ioe.getMessage(), ioe);
        }
        finally
        {
            try
            {
                reader.close();
            }
            catch(final IOException ioe)
            {
                //TODO log!
            }
        }
    }

    @Override
    public void add(final InputStream is)
            throws HttpClientException
    {
        final ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try
        {
            byte buf[] = new byte[4096];
            int read = -1;
            while((read = is.read(buf)) > -1)
            {
                baos.write(buf);
            }
            
            final Item item = new Base64BinaryValue(baos.toByteArray());
            myItems.add(item);
        }
        catch(final IOException ioe)
        {
            throw new HttpClientException(ioe.getMessage(), ioe);
        }
        finally
        {
            try
            {
                baos.close();
            }
            catch(final IOException ioe)
            {
                //TODO log!
            }
            
            try
            {
                is.close();
            }
            catch(final IOException ioe)
            {
                //TODO log!
            }
        }
    }

    @Override
    public void add(final Source src)
            throws HttpClientException
    {
        try {
            final Item doc = myCtxt.getConfiguration().buildDocument(src);
            myItems.add(doc);
        }
        catch ( final XPathException ex ) {
            throw new HttpClientException("Error building the XML or HTML document", ex);
        }
    }

    @Override
    public void add(final HttpResponse response)
            throws HttpClientException
    {
        SaxonTreeBuilder builder = new SaxonTreeBuilder(myCtxt, myNs);
        response.outputResponseElement(builder);
        final Item elem = builder.getCurrentRoot();
        myItems.add(0, elem);
    }

    public SequenceIterator newIterator()
            throws HttpClientException
    {
        final Item[] array = myItems.toArray(new Item[0]);
        return new ArrayIterator(array);
    }

    private List<Item> myItems;
    private XPathContext myCtxt;
    /** The namespace used for the elements. */
    private String myNs;
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
