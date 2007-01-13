//
// $Id$

package com.threerings.msoy.swiftly.data {

import flash.utils.ByteArray;
import com.threerings.util.*; // for Float, Integer, etc.

import com.threerings.msoy.swiftly.client.ProjectRoomService;
import com.threerings.msoy.swiftly.data.PathElement;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ConfirmMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;

/**
 * Provides the implementation of the {@link ProjectRoomService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class ProjectRoomMarshaller extends InvocationMarshaller
    implements ProjectRoomService
{
    /** The method id used to dispatch {@link #addPathElement} requests. */
    public static const ADD_PATH_ELEMENT :int = 1;

    // from interface ProjectRoomService
    public function addPathElement (arg1 :Client, arg2 :PathElement) :void
    {
        sendRequest(arg1, ADD_PATH_ELEMENT, [
            arg2
        ]);
    }

    /** The method id used to dispatch {@link #buildProject} requests. */
    public static const BUILD_PROJECT :int = 2;

    // from interface ProjectRoomService
    public function buildProject (arg1 :Client) :void
    {
        sendRequest(arg1, BUILD_PROJECT, [
            
        ]);
    }

    /** The method id used to dispatch {@link #commitProject} requests. */
    public static const COMMIT_PROJECT :int = 3;

    // from interface ProjectRoomService
    public function commitProject (arg1 :Client, arg2 :String, arg3 :InvocationService_ConfirmListener) :void
    {
        var listener3 :InvocationMarshaller_ConfirmMarshaller = new InvocationMarshaller_ConfirmMarshaller();
        listener3.listener = arg3;
        sendRequest(arg1, COMMIT_PROJECT, [
            arg2, listener3
        ]);
    }

    /** The method id used to dispatch {@link #deletePathElement} requests. */
    public static const DELETE_PATH_ELEMENT :int = 4;

    // from interface ProjectRoomService
    public function deletePathElement (arg1 :Client, arg2 :int) :void
    {
        sendRequest(arg1, DELETE_PATH_ELEMENT, [
            Integer.valueOf(arg2)
        ]);
    }

    /** The method id used to dispatch {@link #updatePathElement} requests. */
    public static const UPDATE_PATH_ELEMENT :int = 5;

    // from interface ProjectRoomService
    public function updatePathElement (arg1 :Client, arg2 :PathElement) :void
    {
        sendRequest(arg1, UPDATE_PATH_ELEMENT, [
            arg2
        ]);
    }
}
}
