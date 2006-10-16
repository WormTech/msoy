//
// $Id$

package com.threerings.msoy.server.persist;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

import com.samskivert.util.StringUtil;

/**
 * Contains the details of person's membership in a group.
 */
@Entity
@Table(uniqueConstraints=@UniqueConstraint(columnNames={
    GroupMembershipRecord.MEMBER_ID, GroupMembershipRecord.GROUP_ID }))
public class GroupMembershipRecord
    implements Cloneable
{
    public static final int SCHEMA_VERSION = 1;

    public static final String MEMBER_ID = "memberId";
    public static final String GROUP_ID = "groupId";
    public static final String RANK = "rank";

    /** The id of the member in the group membership. */
    @Column(nullable=false)
    public int memberId;

    /** The id of the group in the group membership. */ 
    @Column(nullable=false)
    public int groupId;
    
    /** The rank of the member in the group, defined in {@link GroupMembership}. */
    @Column(nullable=false)
    public byte rank;
    
    /**
     * Generates a string representation of this instance.
     */
    @Override
    public String toString ()
    {
        StringBuilder buf = new StringBuilder("[");
        StringUtil.fieldsToString(buf, this);
        return buf.append("]").toString();
    }
}
