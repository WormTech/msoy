//
// $Id$

package com.threerings.msoy.chat.client {

import flash.display.Graphics;

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import mx.core.Container;

import com.threerings.util.HashMap;
import com.threerings.util.Name;

import com.threerings.flash.ColorUtil;

import com.threerings.msoy.client.WorldClient;
import com.threerings.msoy.client.WorldContext;

import com.threerings.crowd.chat.data.ChatCodes;
import com.threerings.crowd.chat.data.ChatMessage;
import com.threerings.crowd.chat.data.UserMessage;

/**
 * Implements comic chat in the metasoy client.
 */
public class ComicOverlay extends ChatOverlay
{
    /**
     * Construct a comic chat overlay.
     */
    public function ComicOverlay (ctx :WorldContext)
    {
        super(ctx.getMessageManager());
        _ctx = ctx;
    }

    /**
     * Called by our target when we've entered a new place.
     */
    public function newPlaceEntered (provider :ChatInfoProvider) :void
    {
        _provider = provider;
        _newPlacePoint = _history.size();

        // and clear place-oriented bubbles
        clearBubbles(false);
    }

    override protected function layout (bounds :Rectangle, targetWidth :int) :void
    {
        clearBubbles(true); // these will get repopulated from the history
        super.layout(bounds, targetWidth);
    }

    override public function setTarget (target :Container, targetWidth :int = -1) :void
    {
        if (_target != null) {
            clearBubbles(true);
        }
        super.setTarget(target, targetWidth);
    }

    override public function clear () :void
    {
        super.clear();
        clearBubbles(true);
    }

    public function speakerMoved (speaker :Name, bounds :Rectangle) :void
    {
        var cloud :BubbleCloud = _bubbles.get(speaker);
        if (cloud != null) {
            // the bounds are in stage coordinates
            var local :Point = _overlay.globalToLocal(bounds.topLeft);
            bounds.x = local.x;
            bounds.y = local.y;
            cloud.setSpeakerLocation(bounds);
        }
    }

    override protected function createStandardFormats () :void
    {
        super.createStandardFormats();

        // Bubbles use copies of the standard subtitle formats, only with align = CENTER.
        _defaultBubbleFmt = new TextFormat(_defaultFmt.font, _defaultFmt.size,
            _defaultFmt.color, _defaultFmt.bold, _defaultFmt.italic, _defaultFmt.underline,
            _defaultFmt.url, _defaultFmt.target, TextFormatAlign.CENTER,
            _defaultFmt.leftMargin, _defaultFmt.rightMargin, _defaultFmt.indent,
            _defaultFmt.leading);
        _userBubbleFmt = new TextFormat(_userSpeakFmt.font, _userSpeakFmt.size,
            _userSpeakFmt.color, _userSpeakFmt.bold, _userSpeakFmt.italic, _userSpeakFmt.underline,
            _userSpeakFmt.url, _userSpeakFmt.target, TextFormatAlign.CENTER,
            _userSpeakFmt.leftMargin, _userSpeakFmt.rightMargin, _userSpeakFmt.indent,
            _userSpeakFmt.leading);
    }

    /**
     * Clear chat bubbles, either all of them or just the place-oriented ones.
     */
    protected function clearBubbles (all :Boolean) :void
    {
        for each (var cloud :BubbleCloud in _bubbles.values()) {
            for each (var bubble :BubbleGlyph in cloud.bubbles) {
                if (all || isPlaceOrientedType(bubble.getType())) {
                    cloud.removeBubble(bubble);
                }
            }
        }
    }

    override internal function historyUpdated (adjustment :int) :void
    {
        _newPlacePoint -= adjustment;
        super.historyUpdated(adjustment);
    }

    override protected function shouldShowFromHistory (msg :ChatMessage, index :int) :Boolean
    {
        // if we're minimized, show nothing
        if ((_ctx.getClient() as WorldClient).isMinimized()) {
            return false;
        }
        // only show if the message was received since we last entered a new place, or if it's
        // place-less chat.
        return ((index >= _newPlacePoint) || (!isPlaceOrientedType(getType(msg, false))));
    }

    override protected function isApprovedLocalType (localtype :String) :Boolean
    {
        if (ChatCodes.PLACE_CHAT_TYPE == localtype || ChatCodes.USER_CHAT_TYPE == localtype) {
            return true;
        }
        log.debug("Ignoring non-standard system/feedback chat [localtype=" + localtype + "].");
        return false;
    }

    /**
     * Is the type of chat place-oriented.
     */
    protected function isPlaceOrientedType (type :int) :Boolean
    {
        return (placeOf(type)) == PLACE;
    }

    override public function displayMessage (msg :ChatMessage, alreadyDisp :Boolean) :Boolean
    {
        if ((_ctx.getClient() as WorldClient).isMinimized()) {
            return false; // no comic messages while minimized
        }
        return super.displayMessage(msg, alreadyDisp);
    }

    override protected function displayTypedMessageNow (msg :ChatMessage, type :int) :Boolean
    {
        switch (placeOf(type)) {
        case INFO:
        case FEEDBACK:
        case ATTENTION:
        case BROADCAST:
            if (createBubble(msg, type, null, null)) {
                return true;
            }
            // if the bubble didn't fit (unlikely), make it a subtitle
            break;

        case PLACE: 
            var umsg :UserMessage = (msg as UserMessage);
            var speaker :Name = umsg.getSpeakerDisplayName();
            var speakerBounds :Rectangle = _provider.getSpeakerBounds(speaker);
            if (speakerBounds == null) {
                log.warning("ChatOverlay.InfoProvider doesn't know the speaker! " +
                    "[speaker=" + speaker + ", type=" + type + "].");
                return false;
            }

            if (createBubble(msg, type, speaker, speakerBounds)) {
                return true;
            }
            // if the bubble didn't fit (unlikely), make it a subtitle
            break;
        }

        // show the message as a subtitle instead
        return super.displayTypedMessageNow(msg, type);
    }

    /**
     * Create a chat bubble with the specified type and text.
     *
     * @param speakerBounds if non-null, contains the bounds of the speaker in screen coordinates
     *
     * @return true if we successfully laid out the bubble
     */
    protected function createBubble (
        msg :ChatMessage, type :int, speaker :Name, speakerBounds :Rectangle) :Boolean
    {
        var texts :Array = formatMessage(msg, type, false, _userBubbleFmt);
        var lifetime :int = getLifetime(msg, true);
        var bubble :BubbleGlyph =
            new BubbleGlyph(this, type, lifetime, speaker, _defaultBubbleFmt, texts);

        var cloud :BubbleCloud = _bubbles.get(speaker);
        if (cloud == null) {
            if (speakerBounds != null) {
                // the bounds given to this function are in stage coordinates
                var local :Point = _overlay.globalToLocal(speakerBounds.topLeft);
                speakerBounds.x = local.x;
                speakerBounds.y = local.y;
            }
            var maxBubbles :int = speaker == null ? MAX_NOTIFICATION_BUBBLES : MAX_BUBBLES_PER_USER;
            cloud = new BubbleCloud(this, maxBubbles, speakerBounds, _target.width, _target.height);
            _bubbles.put(speaker, cloud);
        }
        cloud.addBubble(bubble);
        _overlay.addChild(bubble);

        // TODO: this is a hack and illustrates why my BubbleCloud approach may not be the best 
        // (it'll probably only get worse when we start trying to show the maximal bubbleage 
        // reasonable at once...).  This could be alleviated by just keeping an array of all the 
        // bubbles solely for this reason, but we'll see what we end up doing with bubble placement.
        var allBubbles :Array = [];
        for each (cloud in _bubbles.values()) {
            allBubbles = allBubbles.concat(cloud.bubbles);
        }
        allBubbles.sort(function (bubA :BubbleGlyph, bubB :BubbleGlyph) :int {
            if (bubA.parent != _overlay) {
                if (bubB.parent != _overlay) {
                    return 0;
                } else {
                    return 1;
                }
            } else if (bubB.parent != _overlay) {
                return -1;
            }

            return _overlay.getChildIndex(bubA) > _overlay.getChildIndex(bubB) ? -1 : 1;
        });
        for (var ii :int = 0; ii < allBubbles.length; ii++) {
            (allBubbles[ii] as BubbleGlyph).setAgeLevel(ii);
        }

        return true;
    }

    /**
     * Draw the specified bubble shape.
     *
     * @return the padding that should be applied to the bubble's label.
     */
    internal function drawBubbleShape (g :Graphics, type :int, txtWidth :int, txtHeight :int,
        tail :Boolean) :int
    {
        var outline :uint = getOutlineColor(type);
        var background :uint;
        if (BLACK == outline) {
            background = WHITE;
        } else {
            background = ColorUtil.blend(WHITE, outline, .8);
        }

        var padding :int = getBubbleLabelOffset(type);
        var width :int = txtWidth + padding * 2;
        var height :int = txtHeight + padding * 2;

        var shapeFunction :Function = getBubbleShape(type);

        // clear any old graphics
        g.clear();

        g.lineStyle(1, outline);
        g.beginFill(background);
        shapeFunction(g, width, height);
        g.endFill();

        if (tail) {
            var tailFunction :Function = getTailShape(type);
            if (tailFunction != null) {
                tailFunction(g, width, height, outline, background);
            }
        }

        return padding;
    }

    /**
     * Get the function that draws the bubble shape for the specified type of bubble.
     */
    protected function getBubbleShape (type :int) :Function
    {
        switch (placeOf(type)) {
        case INFO:
        case ATTENTION:
            return drawRectangle;
        }

        switch (modeOf(type)) {
        case SPEAK:
            return drawRoundedBubble;
        case EMOTE:
            return drawEmoteBubble;
        case THINK:
            return drawThinkBubble;
        }

        // fall back to subtitle shape
        return getSubtitleShape(type);
    }

    /**
     * Get the function that draws the tail shape for the specified type of bubble.
     */
    protected function getTailShape (type :int) :Function
    {
        if (placeOf(type) != PLACE) {
            return null;
        }

        switch(modeOf(type)) {
        case SPEAK:
            return drawSpeakTail;
        case THINK:
            return drawThinkTail;
        }

        return null;
    }

    protected function drawSpeakTail (g :Graphics, w :int, h :int, outline :int, fill :int) :void
    {
        // first fill the shape we want
        g.lineStyle(1, fill);
        g.beginFill(fill);
        g.drawRect(w - PAD, h - PAD, PAD, PAD);
        g.moveTo(w - PAD * 3 / 4, h);
        g.curveTo(w - PAD / 4, h + PAD / 4, w - PAD / 2, h + PAD / 2);
        g.curveTo(w, h + PAD * 3 / 8, w, h);
        g.endFill();

        // now draw the border
        g.lineStyle(1, outline);
        g.moveTo(w - PAD - 2, h);
        g.lineTo(w - PAD * 3 / 4, h);
        g.curveTo(w - PAD / 4, h + PAD / 4, w - PAD / 2, h + PAD / 2);
        g.curveTo(w, h + PAD * 3 / 8, w, h);
        g.lineTo(w, h - PAD - 2);
    }

    protected function drawThinkTail (g :Graphics, w :int, h :int, outline :int, fill :int) :void
    {
        g.lineStyle(1, outline);
        g.beginFill(fill);
        g.drawCircle(w - 9, h + 5, 4);
        g.drawCircle(w - 13, h + 14, 3);
        g.endFill();
    }

    /** Bubble draw function. See getBubbleShape() */
    protected function drawRoundedBubble (g :Graphics, w :int, h :int) :void
    {
        g.drawRoundRect(0, 0, w, h, PAD * 2, PAD * 2);
    }

    /** Bubble draw function. See getBubbleShape() */
    protected function drawEmoteBubble (g :Graphics, w :int, h :int) :void
    {
        var hw :Number = w / 2;
        var hh :Number = h / 2;
        g.moveTo(0, 0);
        g.curveTo(hw, PAD * 2, w, 0);
        g.curveTo(w - (PAD * 2), hh, w, h);
        g.curveTo(hw, h - (PAD * 2), 0, h);
        g.curveTo(PAD * 2, hh, 0, 0);
    }

    /** Bubble draw function. See getBubbleShape() */
    protected function drawThinkBubble (g :Graphics, w :int, h :int) :void
    {
        var hDia :int = 16;
        // if we're over halfway to a new bump, sub a little from each bump to fill out a new one
        if ((w - PAD) % hDia > hDia / 2) {
            hDia -= Math.ceil((hDia - ((w - PAD) % hDia)) / Math.floor((w - PAD) / hDia));

        // else if we're less than halfway to a new bump, add a little to each bump.
        } else if ((w - PAD) % hDia != 0) {
            hDia += Math.floor(((w - PAD) % hDia) / Math.floor((w - PAD) / hDia));
        }
        var hBumps :int = Math.round((w - PAD) / hDia);

        var vDia :int = 16;
        // if we're over halfway to a new bump, sub a little from each bump to fill out a new one
        if ((h - PAD) % vDia > vDia / 2) {
            vDia -= Math.ceil((vDia - ((h - PAD) % vDia)) / Math.floor((h - PAD) / vDia));
            
        // else if we're less than halfway to a new bump, add a little to each bump.
        } else if ((h - PAD) % vDia != 0) {
            vDia += Math.floor(((h - PAD) % vDia) / Math.floor((h - PAD) / vDia));
        }
        var vBumps :int = Math.round((h - PAD) / vDia);

        var thinkPad :Number = PAD / 2;

        g.moveTo(thinkPad, thinkPad);

        var yy :int;
        var xx :int;
        var ii :int;

        for (ii = 0, xx = thinkPad; ii < hBumps; ii++, xx += hDia) {
            if (ii == hBumps - 1) {
                g.curveTo((xx + w - thinkPad) / 2, -thinkPad, w - thinkPad, thinkPad);
            } else {
                g.curveTo(xx + hDia / 2, -thinkPad, xx + hDia, thinkPad);
            }
        }

        for (ii = 0, yy = thinkPad; ii < vBumps; ii++, yy += vDia) {
            if (ii == vBumps - 1) {
                g.curveTo(w + thinkPad, (yy + h - thinkPad) / 2, w - thinkPad, h - thinkPad);
            } else {
                g.curveTo(w + thinkPad, yy + vDia / 2, w - thinkPad, yy + vDia);
            }
        }

        for (ii = 0, xx = (w - thinkPad); ii < hBumps; ii++, xx -= hDia) {
            if (ii == hBumps - 1) {
                g.curveTo((xx + thinkPad) / 2, h + thinkPad, thinkPad, h - thinkPad);
            } else {
                g.curveTo(xx - hDia / 2, h + thinkPad, xx - hDia, h - thinkPad);
            }
        }

        for (ii = 0, yy = (h - thinkPad); ii < vBumps; ii++, yy -= vDia)  {
            if (ii == vBumps - 1) {
                g.curveTo(-thinkPad, (yy + thinkPad) / 2, thinkPad, thinkPad);
            } else {
                g.curveTo(-thinkPad, yy - vDia / 2, thinkPad, yy - vDia);
            }
        }
    }

    /**
     * Position the label based on the type.
     */
    protected function getBubbleLabelOffset (type :int) :int
    {
        switch (modeOf(type)) {
        case SHOUT:
        case EMOTE:
        case THINK:
            return (PAD * 2);

        default:
            return PAD;
        }
    }

    override internal function glyphExpired (glyph :ChatGlyph) :void
    {
        if (glyph is BubbleGlyph) {
            var bubble :BubbleGlyph = glyph as BubbleGlyph;
            var cloud :BubbleCloud = _bubbles.get(bubble.getSpeaker());
            cloud.removeBubble(bubble);
        }
        super.glyphExpired(glyph);
    }

    // documentation inherited
    override protected function getDisplayDurationIndex () :int
    {
        // normalize the duration returned by super. Annoying.
        return super.getDisplayDurationIndex() - 1;
    }

    /** Giver of life, context. */
    protected var _ctx :WorldContext;

    /** The provider of info about laying out bubbles. */ 
    protected var _provider :ChatInfoProvider;

    /** A copy of super's _defaultFmt, with a differnent alignment. */
    protected var _defaultBubbleFmt :TextFormat;

    /** A copy of super's _userSpeakFmt, with a different alignment. */
    protected var _userBubbleFmt :TextFormat;

    /** The place in our history at which we last entered a new place. */
    protected var _newPlacePoint :int = 0;

    /** Maps speaker name to BubbleCloud */
    protected var _bubbles :HashMap = new HashMap();

    /** The maximum number of bubbles to show per user. */
    protected static const MAX_BUBBLES_PER_USER :int = 3;

    /** The maximum number of notification bubbles to show. */
    protected static const MAX_NOTIFICATION_BUBBLES :int = 5;
}
}

import flash.geom.Rectangle;

import com.threerings.flash.DisplayUtil;

import com.threerings.msoy.chat.client.BubbleGlyph;
import com.threerings.msoy.chat.client.ComicOverlay;

/**
 * A class to keep track of the bubbles spoken by a speaker.  When the speaker moves, this class
 * is told the new location so that it can layout its bubbles correctly.  This may get nixed or 
 * fancied up on the next pass of bubble layout...
 */
class BubbleCloud 
{
    public function BubbleCloud (overlay :ComicOverlay, maxBubbles :int, bounds :Rectangle, 
        viewWidth :Number, viewHeight :Number) 
    {
        _overlay = overlay;
        _maxBubbles = maxBubbles;
        _location = bounds;
        _viewWidth = viewWidth;
        _viewHeight = viewHeight;
    }

    public function get bubbles () :Array 
    {
        return _bubbles;
    }

    public function setSpeakerLocation (bounds :Rectangle) :void
    {
        _location = bounds;
        if (bounds == null) {
            // BubbleClouds with null speaker bounds are those not being shown in PLACE (non speak, 
            // think, emote, etc), and aren't being placed over an ActorSprite.
            var vbounds :Rectangle = new Rectangle(BUBBLE_SPACING, BUBBLE_SPACING, 
                _viewWidth - BUBBLE_SPACING * 2, _viewHeight - BUBBLE_SPACING * 2);
            var avoidList :Array = [];
            var placeList :Array = [];
            for (var ii :int = 0; ii < _bubbles.length; ii++) {
                var bubble :BubbleGlyph = _bubbles[ii] as BubbleGlyph;
                if (bubble.x != 0 || bubble.y != 0) {
                    avoidList.push(bubble.getBubbleBounds());
                } else {
                    placeList.push(bubble);
                }
            }
            for each (bubble in placeList) {
                var placer :Rectangle = bubble.getBubbleBounds();
                placer.x = BUBBLE_SPACING;
                placer.y = BUBBLE_SPACING;
                if (!DisplayUtil.positionRect(placer, vbounds, avoidList)) {
                    // DANGER! DANGER!
                    Log.getLog(this).warning(
                        "Failed to place notification bubble [avoids=" + avoidList.length + "]");
                }
                bubble.x = placer.x;
                bubble.y = placer.y;
                avoidList.push(placer);
            }
        } else {
            var centerX :Number = bounds.x + bounds.width / 2;
            var yOffset :Number = bounds.y - BUBBLE_SPACING; 
            for each (bubble in _bubbles) {
                var bubBounds :Rectangle = bubble.getBubbleBounds();
                yOffset -= bubBounds.height;
                bubble.x = centerX - bubBounds.width / 2;
                bubble.y = yOffset;
            }
        }
    }

    public function addBubble (bubble :BubbleGlyph) :void
    {
        _bubbles.unshift(bubble);
        while (_bubbles.length > _maxBubbles) {
            _overlay.removeGlyph(_bubbles.pop() as BubbleGlyph);
        }
        for (var ii :int = 1; ii < _bubbles.length; ii++) {
            (_bubbles[ii] as BubbleGlyph).removeTail();
        }
        // refresh the bubble display
        setSpeakerLocation(_location);
    }

    public function removeBubble (bubble :BubbleGlyph) :void
    {
        for (var ii :int = 0; ii < _bubbles.length; ii++) {
            if (_bubbles[ii] == bubble) {
                _bubbles.splice(ii, 1);
                // refresh the bubble display
                setSpeakerLocation(_location);
                break;
            }
        }
        // make sure the bubble gets removed from the overlay, whether we found it here or not.
        _overlay.removeGlyph(bubble);
    }

    /** The space we force between adjacent bubbles. */
    protected static const BUBBLE_SPACING :int = 5;

    protected var _bubbles :Array = [];
    protected var _location :Rectangle;
    protected var _overlay :ComicOverlay;
    protected var _maxBubbles :int;
    protected var _viewWidth :Number;
    protected var _viewHeight :Number;
}
