//
// $Id$

package com.threerings.msoy.data;

import com.threerings.crowd.data.PlaceConfig;

/**
 * Does something extraordinary.
 */
public class SimpleChatConfig extends PlaceConfig
{
    public String getManagerClassName ()
    {
        return "com.threerings.msoy.server.SimpleChatManager";
    }
}
