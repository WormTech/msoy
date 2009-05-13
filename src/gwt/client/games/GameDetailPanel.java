//
// $Id$

package client.games;

import java.util.HashMap;
import java.util.Map;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.logical.shared.BeforeSelectionEvent;
import com.google.gwt.event.logical.shared.BeforeSelectionHandler;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HasAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.PushButton;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;

import com.threerings.gwt.ui.SmartTable;
import com.threerings.gwt.ui.WidgetUtil;

import com.threerings.msoy.comment.gwt.Comment;
import com.threerings.msoy.data.all.MediaDesc;
import com.threerings.msoy.data.all.RatingResult;
import com.threerings.msoy.game.gwt.GameDetail;
import com.threerings.msoy.game.gwt.GameInfo;
import com.threerings.msoy.game.gwt.GameService;
import com.threerings.msoy.game.gwt.GameServiceAsync;
import com.threerings.msoy.item.data.all.Game;
import com.threerings.msoy.web.gwt.Args;
import com.threerings.msoy.web.gwt.Pages;
import com.threerings.msoy.web.gwt.SharedNaviUtil.GameDetails;

import client.comment.CommentsPanel;
import client.game.GameBitsPanel;
import client.game.GameNamePanel;
import client.game.PlayButton;
import client.shell.CShell;
import client.shell.DynamicLookup;
import client.ui.MsoyUI;
import client.ui.Rating;
import client.ui.StyledTabPanel;
import client.ui.ThumbBox;
import client.util.InfoCallback;
import client.util.Link;
import client.util.NaviUtil;
import client.util.ServiceUtil;

/**
 * Displays detail information on a particular game.
 */
public class GameDetailPanel extends SmartTable
    implements BeforeSelectionHandler<Integer>
{
    public GameDetailPanel ()
    {
        super("gameDetail", 0, 10);
    }

    public void setGame (int gameId, final GameDetails tab)
    {
        if (_gameId == gameId) {
            selectTab(tab);
        } else {
            _gamesvc.loadGameDetail(gameId, new InfoCallback<GameDetail>() {
                public void onSuccess (GameDetail detail) {
                    if (detail == null) {
                        MsoyUI.error(_msgs.gdpNoSuchGame());
                    } else {
                        setGameDetail(detail);
                        selectTab(tab);
                    }
                }
            });
        }
    }

    public void setGameDetail (GameDetail detail)
    {
        GameInfo info = detail.info;
        CShell.frame.setTitle(info.name);

        // keep our requested game id around
        _gameId = detail.gameId;

        VerticalPanel shot = new VerticalPanel();
        shot.setHorizontalAlignment(HasAlignment.ALIGN_CENTER);
        shot.add(new ThumbBox(info.shotMedia, MediaDesc.GAME_SHOT_SIZE));
        shot.add(WidgetUtil.makeShim(5, 5));
        Rating rating = new Rating(info.rating, info.ratingCount, detail.memberRating, false) {
            @Override protected void handleRate (
                byte newRating , InfoCallback<RatingResult> callback) {
                _gamesvc.rateGame(_gameId, newRating, callback);
            }
        };
        shot.add(rating);
        HorizontalPanel mbits = new HorizontalPanel();
        mbits.setVerticalAlignment(HorizontalPanel.ALIGN_MIDDLE);
        mbits.add(MsoyUI.makeShareButton(
                      Pages.GAMES, Args.compose("d", _gameId), _dmsgs.xlate("itemType" + Game.GAME),
                      info.name, info.description, info.shotMedia));
        shot.add(mbits);
        setWidget(0, 0, shot);
        getFlexCellFormatter().setRowSpan(0, 0, 2);
        getFlexCellFormatter().setVerticalAlignment(0, 0, HasAlignment.ALIGN_TOP);

        setWidget(0, 1, new GameNamePanel(
                      info.name, info.genre, info.creator, info.description), 2, null);

        setWidget(1, 0, new GameBitsPanel(
                      info.gameId, info.creator.getMemberId(), detail.minPlayers, detail.maxPlayers,
                      detail.metrics.averageDuration, detail.metrics.gamesPlayed));

        FlowPanel play = new FlowPanel();
        play.setStyleName("playPanel");
        play.add(PlayButton.create(_gameId, info.isAVRG, info.groupId, _msgs.gdpNoWhirled(),
                                   PlayButton.Size.LARGE));
        if (info.playersOnline > 0) {
            play.add(MsoyUI.createLabel(_msgs.featuredOnline(""+info.playersOnline), "Online"));
        }
        if (!info.integrated) {
            play.add(MsoyUI.createLabel(_msgs.gdpNoCoins(), null));
        }
        setWidget(1, 1, play, 1, "Play");
        getFlexCellFormatter().setHorizontalAlignment(1, 1, HasAlignment.ALIGN_CENTER);

        // add "Discussions" (if appropriate) and "Shop" button
        Widget buttons = null;
        if (info.groupId > 0) {
            ClickHandler onClick = Link.createListener(
                Pages.GROUPS, Args.compose("f", info.groupId));
            buttons = MsoyUI.createButton(MsoyUI.LONG_THIN, _msgs.gdpDiscuss(), onClick);
        }
        ClickHandler onClick = Link.createListener(Pages.SHOP, Args.compose("g", _gameId));
        PushButton shop = MsoyUI.createButton(MsoyUI.MEDIUM_THIN, _msgs.gdpShop(), onClick);
        buttons = (buttons == null) ? (Widget)shop : MsoyUI.createButtonPair(buttons, shop);
        setWidget(2, 0, buttons);
        getFlexCellFormatter().setRowSpan(0, 0, 3);
        getFlexCellFormatter().setRowSpan(1, 1, 2);

        _tabs = new StyledTabPanel();
        _tabs.addBeforeSelectionHandler(this);
        addWidget(_tabs, 3, null);

        // add the about/instructions tab
        addTab(GameDetails.INSTRUCTIONS, _msgs.tabInstructions(), new InstructionsPanel(detail));

        // add comments tab
        addTab(GameDetails.COMMENTS, _msgs.tabComments(),
               new CommentsPanel(Comment.TYPE_GAME, info.gameId, true));

        // add trophies tab, passing in the potentially negative gameId
        addTab(GameDetails.TROPHIES, _msgs.tabTrophies(), new GameTrophyPanel(_gameId));

        // add top rankings tabs
        if (!CShell.isGuest()) {
            addTab(GameDetails.MYRANKINGS, _msgs.tabMyRankings(),
                   new TopRankingPanel(info.gameId, true));
        }
        addTab(GameDetails.TOPRANKINGS, _msgs.tabTopRankings(),
               new TopRankingPanel(info.gameId, false));

        // if we're the creator of the game or an admin, add the metrics and logs tabs
        if (info.isCreator(CShell.getMemberId()) || CShell.isAdmin()) {
            addTab(GameDetails.METRICS, _msgs.tabMetrics(), new GameMetricsPanel(detail));
            addTab(GameDetails.LOGS, _msgs.tabLogs(), new GameLogsPanel(_gameId));
        }
    }

    // from interface TabListener
    public void onBeforeSelection (BeforeSelectionEvent<Integer> event)
    {
        // route tab selection through the URL
        GameDetails tabCode = getTabCode(event.getItem());
        if (tabCode == _seltab) {
            event.cancel();
            return;
        }
        Link.go(Pages.GAMES, NaviUtil.gameDetail(_gameId, tabCode));
    }

    protected void addTab (GameDetails ident, String title, Widget tab)
    {
        _tabs.add(tab, title);
        _tabmap.put(ident, _tabs.getWidgetCount() - 1);
    }

    protected void selectTab (GameDetails tab)
    {
        Integer tosel = _tabmap.get(tab);
        if (tosel == null) {
            _seltab = getTabCode(0);
            _tabs.selectTab(0);
        } else {
            _seltab = tab;
            _tabs.selectTab(tosel.intValue());
        }
    }

    protected GameDetails getTabCode (int tabIndex)
    {
        for (Map.Entry<GameDetails, Integer> entry : _tabmap.entrySet()) {
            if (entry.getValue() == tabIndex) {
                return entry.getKey();
            }
        }
        return GameDetails.INSTRUCTIONS;
    }

    protected StyledTabPanel _tabs;
    protected int _gameId;
    protected GameDetails _seltab;
    protected Map<GameDetails, Integer> _tabmap = new HashMap<GameDetails, Integer>();

    protected static final DynamicLookup _dmsgs = GWT.create(DynamicLookup.class);
    protected static final GamesMessages _msgs = GWT.create(GamesMessages.class);
    protected static final GameServiceAsync _gamesvc = (GameServiceAsync)
        ServiceUtil.bind(GWT.create(GameService.class), GameService.ENTRY_POINT);
}
