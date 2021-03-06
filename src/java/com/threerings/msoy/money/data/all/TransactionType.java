//
// $Id$

package com.threerings.msoy.money.data.all;

import com.google.gwt.user.client.rpc.IsSerializable;

import com.samskivert.util.ByteEnum;

public enum TransactionType
    implements IsSerializable, ByteEnum
{
    // NOTE: transaction types may be added, removed, or reordered, but the "byteValue" must
    // never change!
    OTHER(0),
    ITEM_PURCHASE(1),
    CREATOR_PAYOUT(2),
    AFFILIATE_PAYOUT(3),
    AWARD(4),
    BLING_POOL(5),
    BARS_BOUGHT(6),
    SPENT_FOR_EXCHANGE(7),
    RECEIVED_FROM_EXCHANGE(8),
    CASHED_OUT(9),
    REQUEST_CASH_OUT(10),
    CANCEL_CASH_OUT(11),
    SUPPORT_ADJUST(12),
    CHARITY_PAYOUT(13),
    CHANGE_IN_COINS(14),
    REFUND_GIVEN(15),
    REFUND_DEDUCTED(16),
    ROOM_PURCHASE(17),
    GROUP_PURCHASE(18),
    CREATED_LISTING(19),
    BROADCAST_PURCHASE(20),
    PARTY_PURCHASE(21),
    FRIEND_AWARD(22),
    BASIS_CREATOR_PAYOUT(23),
    SUBSCRIBER_GRANT(24),
    SUBSCRIPTION_PURCHASE(25),
    THEME_PURCHASE(26),
    ;

    // from ByteEnum
    public byte toByte ()
    {
        return _byteValue;
    }

    /** Constructor. */
    private TransactionType (int byteValue)
    {
        _byteValue = (byte)byteValue;
    }

    /** The byte value. */
    protected transient byte _byteValue;
}
