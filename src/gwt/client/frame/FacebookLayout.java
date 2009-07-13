//
// $Id$

package client.frame;

import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.SimplePanel;
import com.google.gwt.user.client.ui.Widget;

import com.threerings.msoy.data.all.DeploymentConfig;

/**
 * A frame layout that adds an extra iframe below the main gwt page showing facebook information
 * such as friend scores etc.
 */
public class FacebookLayout extends FramedLayout
{
    @Override
    protected void init (FrameHeader header, ClickHandler onGoHome)
    {
        _bottomContent = new SimplePanel();
        super.init(header, onGoHome);
    }

    @Override // from FramedLayout
    public boolean alwaysShowsTitleBar ()
    {
        return true;
    }

    @Override
    public void setTitleBar (TitleBar bar)
    {
        _bar.setWidget(bar.exposeWidget());
    }

    @Override // from Layout
    public void setContent (TitleBar bar, Widget content)
    {
        super.setContent(bar, content);
        _bottomContent.setWidget(null);
    }

    @Override // from Layout
    public void closeContent (boolean restoreClient)
    {
        super.closeContent(restoreClient);
        _bottomContent.setWidget(null);
    }

    @Override // from Layout
    public void setBottomContent (Widget content)
    {
        content.setWidth("100%");
        content.setHeight(FB_FRAME_HEIGHT + "px");
        content.getElement().setAttribute("scrolling", "no");
        if (bottomContentEnabled()) {
            _bottomContent.setWidget(content);
            updateMainContentHeight();
        }
    }

    @Override // from FramedLayout
    protected void addPanels (RootPanel root)
    {
        root.add(_bar);
        root.add(_client);
        root.add(_content);
        root.add(_bottomContent);
    }

    @Override // from FramedLayout
    protected int calcMainContentHeight ()
    {
        int height = super.calcMainContentHeight();
        if (_bottomContent.getWidget() != null) {
            height -= FB_FRAME_HEIGHT;
        }
        return height;
    }

    protected static boolean bottomContentEnabled ()
    {
        // TODO: the bottom content is not yet ready for production
        return DeploymentConfig.devDeployment;
    }

    protected SimplePanel _bottomContent;
    protected static final int FB_FRAME_HEIGHT = 222;
}
