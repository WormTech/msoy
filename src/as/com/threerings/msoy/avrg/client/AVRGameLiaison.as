//
// $Id$

package com.threerings.msoy.avrg.client {

import com.threerings.util.Log;

import com.threerings.presents.client.ClientEvent;

import com.threerings.presents.dobj.AttributeChangeAdapter;
import com.threerings.presents.dobj.AttributeChangedEvent;
import com.threerings.presents.dobj.MessageEvent;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.client.PlaceController;

import com.threerings.msoy.data.MsoyCodes;

import com.threerings.msoy.world.client.WorldContext;

import com.threerings.msoy.game.client.GameLiaison;

import com.threerings.msoy.avrg.client.AVRService_AVRGameJoinListener;
import com.threerings.msoy.avrg.data.AVRGameConfig;
import com.threerings.msoy.avrg.data.AVRGameMarshaller;
import com.threerings.msoy.avrg.data.AVRGameObject;
import com.threerings.msoy.avrg.data.AVRMarshaller;

/**
 * Handles the AVRG-specific aspects of the game server connection.
 */
public class AVRGameLiaison extends GameLiaison
    implements AVRService_AVRGameJoinListener
{
    public const log :Log = Log.getLog(this);

    // statically reference classes we require
    AVRGameMarshaller;
    AVRMarshaller;

    public function AVRGameLiaison (ctx :WorldContext, gameId :int)
    {
        super(ctx, gameId);

        // let the social director spy on us and make suggestions
        _wctx.getSocialDirector().trackAVRGame(_gctx);
    }

    override public function clientWillLogon (event :ClientEvent) :void
    {
        super.clientWillLogon(event);

        // AVRG's need access to the world services, too.
        _gctx.getClient().addServiceGroup(MsoyCodes.WORLD_GROUP);
    }

    override public function clientDidLogon (event :ClientEvent) :void
    {
        super.clientDidLogon(event);

        var svc :AVRService = (_gctx.getClient().requireService(AVRService) as AVRService);
        svc.activateGame(_gctx.getClient(), _gameId, this);

        // Call shutdown when the location is cleared
        var listener :AttributeChangeAdapter;
        listener = new AttributeChangeAdapter(
            function (evt :AttributeChangedEvent) :void {
                if (evt.getName() == BodyObject.LOCATION) {
                    if (evt.getValue() == null) {
                        _gctx.getClient().getClientObject().removeListener(listener);
                        shutdown();
                    }
                }
            });
        _gctx.getClient().getClientObject().addListener(listener);
    }

    // from AVRGameJoinListener
    override public function requestFailed (cause :String) :void
    {
        // GameLiaison conveniently already handles this
        super.requestFailed(cause);

        shutdown();
    }

    // from AVRGameJoinListener
    public function avrgJoined (placeOid :int, config :AVRGameConfig) :void
    {
        // since we hijacked the movement process server-side, let the client catch up
        _gctx.getLocationDirector().didMoveTo(placeOid, config);

        // now that the controller is created, tell it about the world context as well
        getAVRGameController().initializeWorldContext(_wctx);

        // handle deactivations to offer the user to share earned trophies
        getAVRGameController().addDeactivateHandler(onUserDeactivate);
    }

    override public function shutdown () :void
    {
        super.shutdown();
    }

    public function leaveAVRGame () :void
    {
        // remove our trophy feed display stuff
        if (getAVRGameController() == null) {
            log.warning("Controller null on leaveAVRGame?");
        } else {
            getAVRGameController().removeDeactivateHandler(onUserDeactivate);
        }

        var svc :AVRService = (_gctx.getClient().requireService(AVRService) as AVRService);
        svc.deactivateGame(_gctx.getClient(), _gameId,
            _gctx.getWorldContext().confirmListener(_gctx.getLocationDirector().leavePlace,
                null, null, null, "gameId", _gameId));
    }

    /**
     * Returns the backend if we're currently in an AVRG, null otherwise.
     */
    public function getAVRGameBackend () :AVRGameBackend
    {
        var ctrl :AVRGameController = getAVRGameController();
        return (ctrl != null) ? ctrl.backend : null;
    }

    /**
     * Returns the game object if we're currently in an AVRG, null otherwise.
     */
    public function getAVRGameController () :AVRGameController
    {
        var ctrl :PlaceController = _gctx.getLocationDirector().getPlaceController();
        return (ctrl != null) ? (ctrl as AVRGameController) : null;
    }

    // from interface MessageListener
    override public function messageReceived (event :MessageEvent) :void
    {
        super.messageReceived(event);

        if  (event.getName() == AVRGameObject.TASK_COMPLETED_MESSAGE) {
            var coins :int = int(event.getArgs()[1]);
            const forReal :Boolean = Boolean(event.getArgs()[2]);
            const hasCookie :Boolean = true; // we always assume AVRGs have saved state
            if (forReal && _gctx.getPlayerObject().isPermaguest()) {
                // if a guest earns flow, we want to show them the "please register" dialog
                displayGuestFlowEarnage(coins, hasCookie);
            }
        }
    }

    protected function onUserDeactivate () :Boolean
    {
        var tryAgain :Function = getAVRGameController().deactivateGame;
        if (!_wctx.getSocialDirector().mayDeactivateAVRGame(tryAgain)) {
            return false;
        }
        return maybeShowFeedPanel(tryAgain);
    }

    override protected function maybeShowFeedPanel (onClose :Function) :Boolean
    {
        // remove the handler, we don't want to show this twice
        if (getAVRGameController() == null) {
            log.warning("Null controller in showFeedPanel?");
        } else {
            getAVRGameController().removeDeactivateHandler(onUserDeactivate);
        }

        return super.maybeShowFeedPanel(onClose);
    }
}
}
