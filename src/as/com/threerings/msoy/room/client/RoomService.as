//
// $Id$

package com.threerings.msoy.room.client {

import com.threerings.io.TypedArray;
import com.threerings.msoy.item.data.all.ItemIdent;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.client.InvocationService_ResultListener;
import com.threerings.whirled.data.SceneUpdate;
import com.threerings.whirled.spot.data.Location;
import flash.utils.ByteArray;

/**
 * An ActionScript version of the Java RoomService interface.
 */
public interface RoomService extends InvocationService
{
    // from Java interface RoomService
    function changeLocation (arg1 :Client, arg2 :ItemIdent, arg3 :Location) :void;

    // from Java interface RoomService
    function despawnMob (arg1 :Client, arg2 :int, arg3 :String, arg4 :InvocationService_InvocationListener) :void;

    // from Java interface RoomService
    function editRoom (arg1 :Client, arg2 :InvocationService_ResultListener) :void;

    // from Java interface RoomService
    function jumpToSong (arg1 :Client, arg2 :int, arg3 :InvocationService_InvocationListener) :void;

    // from Java interface RoomService
    function modifyPlaylist (arg1 :Client, arg2 :int, arg3 :Boolean, arg4 :InvocationService_ConfirmListener) :void;

    // from Java interface RoomService
    function moveMob (arg1 :Client, arg2 :int, arg3 :String, arg4 :Location, arg5 :InvocationService_InvocationListener) :void;

    // from Java interface RoomService
    function publishRoom (arg1 :Client, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface RoomService
    function rateRoom (arg1 :Client, arg2 :int, arg3 :InvocationService_InvocationListener) :void;

    // from Java interface RoomService
    function requestControl (arg1 :Client, arg2 :ItemIdent) :void;

    // from Java interface RoomService
    function sendPostcard (arg1 :Client, arg2 :TypedArray /* of class java.lang.String */, arg3 :String, arg4 :String, arg5 :String, arg6 :InvocationService_ConfirmListener) :void;

    // from Java interface RoomService
    function sendSpriteMessage (arg1 :Client, arg2 :ItemIdent, arg3 :String, arg4 :ByteArray, arg5 :Boolean) :void;

    // from Java interface RoomService
    function sendSpriteSignal (arg1 :Client, arg2 :String, arg3 :ByteArray) :void;

    // from Java interface RoomService
    function setActorState (arg1 :Client, arg2 :ItemIdent, arg3 :int, arg4 :String) :void;

    // from Java interface RoomService
    function songEnded (arg1 :Client, arg2 :int) :void;

    // from Java interface RoomService
    function spawnMob (arg1 :Client, arg2 :int, arg3 :String, arg4 :String, arg5 :Location, arg6 :InvocationService_InvocationListener) :void;

    // from Java interface RoomService
    function updateMemory (arg1 :Client, arg2 :ItemIdent, arg3 :String, arg4 :ByteArray, arg5 :InvocationService_ResultListener) :void;

    // from Java interface RoomService
    function updateRoom (arg1 :Client, arg2 :SceneUpdate, arg3 :InvocationService_InvocationListener) :void;
}
}
