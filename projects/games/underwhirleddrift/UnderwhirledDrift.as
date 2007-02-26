package {

import flash.display.Sprite;
import flash.display.Shape;

import flash.geom.Point;

import flash.events.KeyboardEvent;

import flash.ui.Keyboard;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import com.threerings.ezgame.EZGameControl;
import com.threerings.ezgame.HostCoordinator;
import com.threerings.ezgame.HostEvent;
import com.threerings.ezgame.PropertyChangedListener;
import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.StateChangedListener;
import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.MessageReceivedListener;
import com.threerings.ezgame.MessageReceivedEvent;

import com.threerings.util.ArrayUtil;

[SWF(width="711", height="400")]
public class UnderwhirledDrift extends Sprite
    implements PropertyChangedListener, StateChangedListener, MessageReceivedListener
{
    /** width of the masked display */
    public static const DISPLAY_WIDTH :int = 711;

    /** height of the masked display */
    public static const DISPLAY_HEIGHT :int = 400;

    /** height of the sky */
    public static const SKY_HEIGHT :int = DISPLAY_HEIGHT * 0.4;

    /** Kart location, relative to the ground coordinates */
    public static const KART_LOCATION :Point = new Point (355, 200);

    /** Kart offset from its effective location */
    public static const KART_OFFSET :int = 32;

    public function UnderwhirledDrift ()
    {
        var masker :Shape = new Shape();
        masker.graphics.beginFill(0xFFFFFF);
        masker.graphics.drawRect(0, 0, DISPLAY_WIDTH, DISPLAY_HEIGHT);
        masker.graphics.endFill();
        this.mask = masker;
        addChild(masker);

        // "sky"
        var colorBackground :Shape = new Shape();
        colorBackground.graphics.beginFill(0x8888FF);
        colorBackground.graphics.drawRect(0, 0, DISPLAY_WIDTH, SKY_HEIGHT + 10);
        colorBackground.graphics.endFill();
        addChild(colorBackground);

        var camera :Camera = new Camera();

        var ground :Ground = new Ground(camera);
        ground.y = SKY_HEIGHT;
        addChild(ground);

        _level = LevelFactory.createLevel(0, ground);
        ground.setLevel(_level);

        _kart = new Kart(camera, ground);
        _kart.x = KART_LOCATION.x;
        // tack on a few pixels to account for the front of the kart
        _kart.y = KART_LOCATION.y + SKY_HEIGHT + KART_OFFSET;
        addChild(_kart);

        _gameCtrl = new EZGameControl(this);
        _gameCtrl.registerListener(this);
        _gameCtrl.addEventListener(KeyboardEvent.KEY_DOWN, keyDownEventHandler);
        _gameCtrl.addEventListener(KeyboardEvent.KEY_UP, keyUpEventHandler);

        _coord = new HostCoordinator(_gameCtrl);
        _coord.addEventListener(HostEvent.CLAIMED, hostEventHandler);
        _coord.addEventListener(HostEvent.CHANGED, hostEventHandler);

        // names obove characters is good, but they should fade out after the race 
        // starts
        /*
        var nameText :TextField = new TextField();
        nameText.text = _gameCtrl.getOccupantName(_gameCtrl.getMyId());
        nameText.selectable = false;
        nameText.autoSize = TextFieldAutoSize.CENTER;
        nameText.scaleX = nameText.scaleY = 2.5;
        nameText.x = _kart.x - nameText.width / 2;
        nameText.y = _kart.y - _kart.height - 5;
        addChild(nameText);*/
    }

    // from StateChangedListener
    public function stateChanged (event :StateChangedEvent) :void
    {
        if (event.type == StateChangedEvent.GAME_STARTED) {
            _gameCtrl.localChat("Game Started");
            if (_coord.status == HostCoordinator.STATUS_HOST) {
                // assign everyone a starting position.
                var playerIds :Array = _gameCtrl.seating.getPlayerIds();
                ArrayUtil.shuffle(playerIds);
                for (var ii :int = 0; ii < playerIds.length; ii++) {
                    playerIds[ii] = { id: playerIds[ii], position: ii }
                }
                _gameCtrl.set("playerPositions", playerIds);
            }
        }
    }

    // from PropertyChangedListener
    public function propertyChanged (event :PropertyChangedEvent) :void
    {
        var name :String = event.name;
        if (name == "playerPositions") {
            var playerPositions :Array = event.newValue as Array;
            for (var ii: int = 0; ii < playerPositions.length; ii++) {
                if (playerPositions[ii].id == _gameCtrl.getMyId()) {
                    _level.setStartingPosition(playerPositions[ii].position);
                    break;
                }
            }
        }
    }

    // from MessageReceivedListener
    public function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.name == "keyDown" || event.name == "keyUp") {
            if (event.value.id == _gameCtrl.getMyId()) {
                switch (event.value.code) {
                case Keyboard.UP:
                    _kart.moveForward(event.name == "keyDown");
                    break;
                case Keyboard.DOWN:
                    _kart.moveBackward(event.name == "keyDown");
                    break;
                case Keyboard.LEFT:
                    _kart.turnLeft(event.name == "keyDown");
                    break;
                case Keyboard.RIGHT:
                    _kart.turnRight(event.name == "keyDown");
                    break;
                case Keyboard.SPACE:
                    if (event.name == "keyDown") {
                        _kart.jump();
                    }
                default:
                    // do nothing
                }
            }
        }
    }

    protected function hostEventHandler (event :HostEvent)  :void
    {
        _gameCtrl.localChat("HostEvent triggered");
        if (_coord.status == HostCoordinator.STATUS_HOST) {
            if (event.type == HostEvent.CLAIMED) {
                _gameCtrl.localChat("I've been assigned host");
            } else if (event.type == HostEvent.CHANGED) {
                // Do nothing for now
            }
        }
    }

    /** 
     * Handles KEY_DOWN. 
     */
    protected function keyDownEventHandler (event :KeyboardEvent) :void
    {
        /*switch (event.keyCode) {
        case Keyboard.UP:
            _kart.moveForward(true);
            break;
        case Keyboard.DOWN:
            _kart.moveBackward(true);
            break;
        case Keyboard.LEFT:
            _kart.turnLeft(true);
            break;
        case Keyboard.RIGHT:
            _kart.turnRight(true);
            break;
        case Keyboard.SPACE:
            _kart.jump();
            break;
        default:
            // do nothing
        }*/
        switch (event.keyCode) {
        case Keyboard.UP:
        case Keyboard.DOWN:
        case Keyboard.LEFT:
        case Keyboard.RIGHT:
        case Keyboard.SPACE:
            _gameCtrl.sendMessage("keyDown", {id: _gameCtrl.getMyId(), code: event.keyCode});
        default:
            // do nothing
        }
    }

    protected function keyUpEventHandler (event :KeyboardEvent) :void
    {
        /*switch (event.keyCode) {
        case Keyboard.UP:
            _kart.moveForward(false);
            break;
        case Keyboard.DOWN:
            _kart.moveBackward(false);
            break;
        case Keyboard.LEFT:
            _kart.turnLeft(false);
            break;
        case Keyboard.RIGHT:
            _kart.turnRight(false);
            break;
        default:
            // do nothing
        }*/
        switch (event.keyCode) {
        case Keyboard.UP:
        case Keyboard.DOWN:
        case Keyboard.LEFT:
        case Keyboard.RIGHT:
        case Keyboard.SPACE:
            _gameCtrl.sendMessage("keyUp", {id: _gameCtrl.getMyId(), code: event.keyCode});
        default:
            // do nothing
        }
    }

    /** the game control. */
    protected var _gameCtrl :EZGameControl;

    /** The host coordinator */
    protected var _coord :HostCoordinator;

    /** The level object */
    protected var _level :Level;

    /** The kart. */
    protected var _kart :Kart;
}
}
