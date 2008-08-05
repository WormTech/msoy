//
// $Id$

package client.me;

import java.util.List;

import com.google.gwt.core.client.GWT;

import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.VerticalPanel;

import com.threerings.gwt.ui.InlineLabel;

import com.threerings.msoy.badge.data.all.Badge;

import com.threerings.msoy.person.gwt.MeService;
import com.threerings.msoy.person.gwt.MeServiceAsync;

import client.ui.Marquee;
import client.ui.MsoyUI;
import client.util.MsoyCallback;
import client.util.ServiceUtil;

public class PassportPanel extends VerticalPanel
{
    public PassportPanel ()
    {
        setStyleName("passport");

        _mesvc.loadBadges(CMe.ident, new MsoyCallback<List<Badge>>() {
            public void onSuccess (List<Badge> badges) {
                init(badges);
            }
        });
    }

    protected void init (List<Badge> badges)
    {
        add(new NextPanel());
    }

    protected static class NextPanel extends VerticalPanel
    {
        public NextPanel ()
        {
            setStyleName("NextPanel");

            HorizontalPanel header = new HorizontalPanel();
            header.add(MsoyUI.createImage("/images/me/passport_icon.png", "Icon"));
            header.add(MsoyUI.createLabel(_msgs.passportDescription(), "Description"));
            header.add(new Marquee(null, _msgs.passportMarquee()));
            add(header);
        }
    }

    protected static final MeMessages _msgs = GWT.create(MeMessages.class);
    protected static final MeServiceAsync _mesvc = (MeServiceAsync)
        ServiceUtil.bind(GWT.create(MeService.class), MeService.ENTRY_POINT);
}
