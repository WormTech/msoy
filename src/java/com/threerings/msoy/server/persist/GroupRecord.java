//
// $Id$

package com.threerings.msoy.server.persist;

import java.sql.Timestamp;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

import com.samskivert.util.StringUtil;
import com.threerings.msoy.web.data.Group;

/**
 * Contains the details of a group.
 */
@Entity
public class GroupRecord
    implements Cloneable
{
    public static final int SCHEMA_VERSION = 1;

    public static final String GROUP_ID = "groupId";
    public static final String NAME = "name";
    public static final String CHARTER = "charter";
    public static final String LOGO_MIME_TYPE = "logoMimeType";
    public static final String LOGO_MEDIA_HASH = "logoMediaHash";
    public static final String CREATOR_ID = "creatorId";
    public static final String CREATION_DATE = "creationDate";
    public static final String POLICY = "policy";

    /** The unique id of this group. */
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    public int groupId;

    /** The name of the group. */
    @Column(nullable=false)
    public String name;

    /** The group's charter, or null if one has yet to be set. */
    @Column(nullable=true, length=2048)
    public String charter;
    
    /** The MIME type of this group's logo. */
    @Column(nullable=true)
    public byte logoMimeType;

    /** A hash code identifying the media for this group's logo. */
    @Column(nullable=true)
    public byte[] logoMediaHash;

    /** The member id of the person who created the group. */
    @Column(nullable=false)
    public int creatorId;
    
    /** The date and time this group was created. */
    @Column(nullable=false)
    public Timestamp creationDate;

    /** The group may be public, invite-only or exclusive as per {@link Group}. */
    @Column(nullable=false)
    public byte policy;
    
    /**
     * CreateS a web-safe version of this group.
     */
    public Group toGroup ()
    {
        Group group = new Group();
        group.groupId = groupId;
        group.name = name;
        group.charter = charter;
        group.logoMimeType = logoMimeType;
        group.logoMediaHash = logoMediaHash.clone();
        group.creatorId = creatorId;
        group.creationDate = new Date(creationDate.getTime());
        group.policy = policy;
        return group;
    }

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
