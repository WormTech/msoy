//
// $Id$

package com.threerings.msoy.chat.data {

import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.client.InvocationService_ResultListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ResultMarshaller;

import com.threerings.msoy.chat.client.JabberService;
import com.threerings.msoy.data.all.JabberName;

/**
 * Provides the implementation of the <code>JabberService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class JabberMarshaller extends InvocationMarshaller
    implements JabberService
{
    /** The method id used to dispatch <code>registerIM</code> requests. */
    public static const REGISTER_IM :int = 1;

    // from interface JabberService
    public function registerIM (arg1 :String, arg2 :String, arg3 :String, arg4 :InvocationService_InvocationListener) :void
    {
        var listener4 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener4.listener = arg4;
        sendRequest(REGISTER_IM, [
            arg1, arg2, arg3, listener4
        ]);
    }

    /** The method id used to dispatch <code>sendMessage</code> requests. */
    public static const SEND_MESSAGE :int = 2;

    // from interface JabberService
    public function sendMessage (arg1 :JabberName, arg2 :String, arg3 :InvocationService_ResultListener) :void
    {
        var listener3 :InvocationMarshaller_ResultMarshaller = new InvocationMarshaller_ResultMarshaller();
        listener3.listener = arg3;
        sendRequest(SEND_MESSAGE, [
            arg1, arg2, listener3
        ]);
    }

    /** The method id used to dispatch <code>unregisterIM</code> requests. */
    public static const UNREGISTER_IM :int = 3;

    // from interface JabberService
    public function unregisterIM (arg1 :String, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(UNREGISTER_IM, [
            arg1, listener2
        ]);
    }
}
}
