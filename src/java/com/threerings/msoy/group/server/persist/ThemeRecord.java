//
// $Id: $

package com.threerings.msoy.group.server.persist;

import com.samskivert.depot.Key;
import com.samskivert.depot.PersistentRecord;
import com.samskivert.depot.annotation.Column;
import com.samskivert.depot.annotation.Entity;
import com.samskivert.depot.annotation.Id;
import com.samskivert.depot.expression.ColumnExp;
import com.threerings.msoy.data.all.GroupName;
import com.threerings.msoy.data.all.MediaDesc;
import com.threerings.msoy.data.all.Theme;

/**
 *  Contains data specific to the theme aspect of a group.
 */
@Entity
public class ThemeRecord extends PersistentRecord
{
    // AUTO-GENERATED: FIELDS START
    public static final Class<ThemeRecord> _R = ThemeRecord.class;
    public static final ColumnExp GROUP_ID = colexp(_R, "groupId");
    public static final ColumnExp PLAY_ON_ENTER = colexp(_R, "playOnEnter");
    public static final ColumnExp LOGO_MEDIA_HASH = colexp(_R, "logoMediaHash");
    public static final ColumnExp LOGO_MIME_TYPE = colexp(_R, "logoMimeType");
    public static final ColumnExp LOGO_MEDIA_CONSTRAINT = colexp(_R, "logoMediaConstraint");
    public static final ColumnExp NAV_MEDIA_HASH = colexp(_R, "navMediaHash");
    public static final ColumnExp NAV_MIME_TYPE = colexp(_R, "navMimeType");
    public static final ColumnExp NAV_MEDIA_CONSTRAINT = colexp(_R, "navMediaConstraint");
    public static final ColumnExp NAV_SEL_MEDIA_HASH = colexp(_R, "navSelMediaHash");
    public static final ColumnExp NAV_SEL_MIME_TYPE = colexp(_R, "navSelMimeType");
    public static final ColumnExp NAV_SEL_MEDIA_CONSTRAINT = colexp(_R, "navSelMediaConstraint");
    public static final ColumnExp BACKGROUND_COLOR = colexp(_R, "backgroundColor");
    // AUTO-GENERATED: FIELDS END

    /** Increment this value if you modify the definition of this persistent object in a way that
     * will result in a change to its SQL counterpart. */
    public static final int SCHEMA_VERSION = 5;

    /** The groupId of this theme. */
    @Id
    public int groupId;

    /** Whether or not to start this theme group's associated AVRG upon entering a themed room. */
    public boolean playOnEnter;

    /** A hash code identifying the media for this theme's logo. */
    @Column(nullable=true)
    public byte[] logoMediaHash;

    /** The MIME type of this theme's logo. */
    public byte logoMimeType;

    /** The constraint for the logo image. */
    public byte logoMediaConstraint;

    /** A hash code identifying the media for this theme's nav button. */
    @Column(nullable=true)
    public byte[] navMediaHash;

    /** The MIME type of this theme's nav button. */
    public byte navMimeType;

    /** The constraint for the nav image. */
    public byte navMediaConstraint;

    /** A hash code identifying the media for this theme's selected nav button. */
    @Column(nullable=true)
    public byte[] navSelMediaHash;

    /** The MIME type of this theme's selected nav button. */
    public byte navSelMimeType;

    /** The constraint for the selected nav image. */
    public byte navSelMediaConstraint;

    /** The background colour of the main Whirled UI. */
    public int backgroundColor = Theme.DEFAULT_THEME.backgroundColor;

    public ThemeRecord ()
    {
    }

    public ThemeRecord (int groupId)
    {
        this.groupId = groupId;
    }

    /**
     * Creates a Theme of this record.
     */
    public Theme toTheme (GroupName group)
    {
        return new Theme(
            group, playOnEnter, toLogo(), toNavButton(), toNavSelButton(), backgroundColor);
    }

    /**
     * Creates a MediaDesc of the theme logo, or returns null if there is none.
     */
    public MediaDesc toLogo ()
    {
        if (logoMediaHash == null) {
            return null;
        }
        return new MediaDesc(logoMediaHash, logoMimeType, logoMediaConstraint);
    }

    /**
     * Creates a MediaDesc of the theme nav button, or returns null if there is none.
     */
    public MediaDesc toNavButton ()
    {
        if (navMediaHash == null) {
            return null;
        }
        return new MediaDesc(navMediaHash, navMimeType, navMediaConstraint);
    }

    /**
     * Creates a MediaDesc of the theme selected nav button, or returns null if there is none.
     */
    public MediaDesc toNavSelButton ()
    {
        if (navSelMediaHash == null) {
            return null;
        }
        return new MediaDesc(navSelMediaHash, navSelMimeType, navSelMediaConstraint);
    }

    // AUTO-GENERATED: METHODS START
    /**
     * Create and return a primary {@link Key} to identify a {@link ThemeRecord}
     * with the supplied key values.
     */
    public static Key<ThemeRecord> getKey (int groupId)
    {
        return new Key<ThemeRecord>(
                ThemeRecord.class,
                new ColumnExp[] { GROUP_ID },
                new Comparable[] { groupId });
    }
    // AUTO-GENERATED: METHODS END

}
