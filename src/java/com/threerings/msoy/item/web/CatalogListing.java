//
// $Id$

package com.threerings.msoy.item.web;

import java.util.Date;

import com.google.gwt.user.client.rpc.IsSerializable;

import com.threerings.io.Streamable;

import com.threerings.msoy.web.data.MemberGName;

/**
 * Represents a catalog listing of an item.
 */
public class CatalogListing
    implements Streamable, IsSerializable
{
    /** The item being listed. */
    public Item item;

    /** The date on which the item was listed. */
    public Date listedDate;

    /** The creator of the item. */
    public MemberGName creator;

    /** The current price of the item. */
    public int price;
}
