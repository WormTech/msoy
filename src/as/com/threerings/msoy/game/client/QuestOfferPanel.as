//
// $Id: QuestOfferPanel.as 4826 2007-06-20 20:07:25Z mdb $

package com.threerings.msoy.game.client {

import mx.controls.Button;

import com.threerings.util.CommandEvent;
import com.threerings.util.MessageBundle;

import com.threerings.msoy.client.WorldContext;
import com.threerings.msoy.client.Msgs;

import com.threerings.msoy.data.all.MemberName;

import com.threerings.msoy.ui.FloatingPanel;
import com.threerings.msoy.ui.MsoyUI;

public class QuestOfferPanel extends FloatingPanel
{
    public static const DECLINE_BUTTON :int = -1;
    public static const ACCEPT_BUTTON :int = -2;

    public function QuestOfferPanel (ctx :GameContext, intro :String, accept :Function)
    {
        super(ctx.getWorldContext(), Msgs.GAME.get("t.quest_offer"));
        _gctx = ctx;
        _intro = intro;
        _accept = accept;
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        addChild(MsoyUI.createLabel(Msgs.GAME.get("m.quest_offer")));
        addChild(MsoyUI.createLabel(_intro));

        addButtons(DECLINE_BUTTON, ACCEPT_BUTTON);
    }

    override protected function createButton (buttonId :int) :Button
    {
        var btn :Button;
        if (buttonId == ACCEPT_BUTTON) {
            btn = new Button();
            btn.label = Msgs.GAME.get("b.accept_quest");
            return btn;
        }
        if (buttonId == DECLINE_BUTTON) {
            btn = new Button();
            btn.label = Msgs.GAME.get("b.decline_quest");
            return btn;
        }

        return super.createButton(buttonId);
    }

    override protected function buttonClicked (buttonId :int) :void
    {
        if (buttonId == ACCEPT_BUTTON) {
            _accept();
        } else if (buttonId != DECLINE_BUTTON) {
            return super.buttonClicked(buttonId);
        }
        close();
    }

    protected var _gctx :GameContext;
    protected var _svc :AVRGameService;

    protected var _accept :Function;
    protected var _intro :String;
}
}
