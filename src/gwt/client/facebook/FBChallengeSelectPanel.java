//
// $Id$

package client.facebook;

import client.shell.ShellMessages;
import client.ui.BorderedDialog;
import client.ui.MsoyUI;
import client.util.InfoCallback;
import client.util.Link;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.Command;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.PushButton;
import com.threerings.msoy.facebook.gwt.FacebookService;
import com.threerings.msoy.facebook.gwt.FacebookServiceAsync;
import com.threerings.msoy.web.gwt.ArgNames;
import com.threerings.msoy.web.gwt.Args;
import com.threerings.msoy.web.gwt.Pages;

/**
 * Just shows 3 buttons that direct to different target audiences.
 */
public class FBChallengeSelectPanel extends FlowPanel
{
    public FBChallengeSelectPanel (Args challengeArgs, String gameName, final boolean mochi)
    {
        setStyleName("challengeSelect");
        add(MsoyUI.createLabel(_msgs.challengeSelect(gameName), "Title"));
        HorizontalPanel buttons = new HorizontalPanel();
        buttons.setHorizontalAlignment(HasHorizontalAlignment.ALIGN_CENTER);
        buttons.setStyleName("Buttons");
        final String gameId = challengeArgs.get(1, "");
        buttons.add(easyButton(_msgs.challengeAllFriendsBtn(), "AllFriends", new ClickHandler() {
            public void onClick (ClickEvent event) {
                confirmAndSendChallenge(mochi, gameId, false);
            }
        }));
        buttons.add(easyButton(_msgs.challengeAppFriendsBtn(), "AppFriends", new ClickHandler() {
            public void onClick (ClickEvent event) {
                confirmAndSendChallenge(mochi, gameId, true);
            }
        }));
        buttons.add(easyButton(_msgs.challengeSomeFriendsBtn(), "SomeFriends",
            Link.createHandler(Pages.FACEBOOK, challengeArgs, ArgNames.FB_CHALLENGE_PICK)));
        add(buttons);
    }

    protected PushButton easyButton (String text, String style, ClickHandler handler)
    {
        PushButton button = MsoyUI.createImageButton("easyButton", handler);
        button.setText(text);
        button.addStyleName(style);
        return button;
    }

    protected void confirmAndSendChallenge (boolean mochi, String gameId, final boolean appOnly)
    {
        final Pages page = mochi ? Pages.GAMES : Pages.WORLD;
        final Args args = mochi ?
            Args.compose("mochi", gameId) :
            Args.compose("game", "p", gameId);

        final Command send = new Command() {
            @Override public void execute () {
                _fbsvc.sendChallengeNotification(appOnly, new InfoCallback<Void>() {
                    @Override public void onSuccess (Void result) {
                        Link.go(page, args);
                    }
                });
            }
        };

        BorderedDialog confirm = new BorderedDialog() {
            /* Constructor() */ {
                setStyleName("challengeConfirm");
                setHeaderTitle(_msgs.challengeConfirmTitle());
                setContents(MsoyUI.createLabel(appOnly ? _msgs.challengeAppFriendsConfirm() :
                    _msgs.challengeAllFriendsConfirm(), "Content"));
                addButton(new Button(_msgs.challengeSendBtn(), onAction(send)));
                addButton(new Button(_msgs.challengeCancelBtn(), onAction(null)));
            }
        };
        confirm.show();
    }

    protected static final FacebookMessages _msgs = GWT.create(FacebookMessages.class);
    protected static final ShellMessages _cmsgs = GWT.create(ShellMessages.class);
    protected static final FacebookServiceAsync _fbsvc = GWT.create(FacebookService.class);
}
