//
// $Id: $

package com.threerings.msoy.data.all;

import com.google.gwt.user.client.rpc.IsSerializable;

import com.threerings.io.SimpleStreamableObject;
import com.threerings.msoy.data.all.GroupName;
import com.threerings.msoy.data.all.MediaDesc;

/**
 *  Contains the definition of a Theme.
 */
public class Theme extends SimpleStreamableObject
    implements IsSerializable
{
    public static final Theme DEFAULT_THEME = createDefaultTheme();

    /** Identifies the logo media. */
    public static final String LOGO_MEDIA = "logo";

    /** Identifies the nav button media. */
    public static final String NAV_MEDIA = "nav";

    /** Identifies the nav button media. */
    public static final String NAV_SEL_MEDIA = "navsel";

    /** The group of this theme. */
    public GroupName group;

    /** The media of the theme's Whirled logo replacement image. */
    public MediaDesc logo;

    /** The media of the theme's Whirled nav button replacement image. */
    public MediaDesc navButton;

    /** The media of the theme's Whirled nav selected button replacement image. */
    public MediaDesc navSelButton;

    /** Whether or not we start playing this group's associated AVRG upon room entry. */
    public boolean playOnEnter;

    /** The background colour of the main Whirled UI. */
    public int backgroundColor;

    /**
     * An empty constructor for deserialization
     */
    public Theme ()
    {
    }

    /**
     * An initialization constructor.
     */
    public Theme (GroupName group, boolean playOnEnter, MediaDesc logo, MediaDesc navButton,
        MediaDesc navSelButton, int backgroundColor)
    {
        this.group = group;
        this.playOnEnter = playOnEnter;
        this.logo = logo;
        this.navButton = navButton;
        this.navSelButton = navSelButton;
        this.backgroundColor = backgroundColor;
    }

    /**
     * Returns this group's logo, or the default.
     */
    public MediaDesc getLogo ()
    {
        return (logo != null) ? logo : getDefaultThemeLogoMedia();
    }

    /**
     * Returns this group's nav button, or the default.
     */
    public MediaDesc getNavButton ()
    {
        return (navButton != null) ? navButton : getDefaultThemeNavButtonMedia();
    }

    /**
     * Returns this group's nav selected button, or the default.
     */
    public MediaDesc getNavSelButton ()
    {
        return (navSelButton != null) ? navSelButton : getDefaultThemeNavSelButtonMedia();
    }

    public int getGroupId ()
    {
        return (group != null) ? group.getGroupId() : 0;
    }

    @Override
    public int hashCode ()
    {
        return getGroupId();
    }

    @Override
    public boolean equals (Object o)
    {
        if (!(o instanceof Theme)) {
            return false;
        }
        Theme other = (Theme)o;
        if (playOnEnter != other.playOnEnter) {
            return false;
        }
        return ((group != null) ? group.equals(other.group) : (other.group == null));
    }

    /**
     * Creates a default logo for use with groups that have no logo.
     */
    protected static MediaDesc getDefaultThemeLogoMedia ()
    {
        return new InternalMediaDesc(DEFAULT_LOGO_URL, MediaDesc.IMAGE_PNG,
            Theme.LOGO_MEDIA, MediaDesc.HORIZONTALLY_CONSTRAINED);
    }

    /**
     * Creates a default nav button for use with groups that have none.
     */
    protected static MediaDesc getDefaultThemeNavButtonMedia ()
    {
        return new InternalMediaDesc(DEFAULT_NAV_URL, MediaDesc.IMAGE_PNG,
            Theme.NAV_MEDIA, MediaDesc.HORIZONTALLY_CONSTRAINED);
    }

    /**
     * Creates a default nav button for use with groups that have none.
     */
    protected static MediaDesc getDefaultThemeNavSelButtonMedia ()
    {
        return new InternalMediaDesc(DEFAULT_NAV_SEL_URL, MediaDesc.IMAGE_PNG,
            Theme.NAV_MEDIA, MediaDesc.HORIZONTALLY_CONSTRAINED);
    }

    protected static Theme createDefaultTheme ()
    {
        return new Theme(null, false, getDefaultThemeLogoMedia(),
            getDefaultThemeNavButtonMedia(), getDefaultThemeNavSelButtonMedia(),
            DEFAULT_BACKGROUND_COLOR);
    }

    /** The internal paths for various themable assets. */
    protected static final String DEFAULT_LOGO_URL = "/images/header/header_logo";
    protected static final String DEFAULT_NAV_URL = "/images/header/navi_button_bg";
    protected static final String DEFAULT_NAV_SEL_URL = "/images/header/navi_button_selected_bg";

    /** The default colour of the web header background. */
    protected static final int DEFAULT_BACKGROUND_COLOR = 0xFFFFFF;
}
