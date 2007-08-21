//
// $Id$

package com.threerings.msoy.world.client.editor {

import flash.events.Event;

import mx.binding.utils.BindingUtils;
import mx.containers.Grid;
import mx.containers.HBox;
import mx.controls.HSlider;
import mx.controls.TextInput;
import mx.controls.ToggleButtonBar;
import mx.events.FlexEvent;
import mx.events.ItemClickEvent;
import mx.events.SliderEvent;

import com.threerings.flex.GridUtil;
import com.threerings.msoy.client.Msgs;
import com.threerings.msoy.world.data.FurniData;
import com.threerings.msoy.world.data.MsoyScene;
import com.threerings.msoy.world.data.MsoySceneModel;

/**
 * Displays details about the room.
 */
public class RoomPanel extends BasePanel
{
    public function RoomPanel (controller :RoomEditorController)
    {
        super(controller);
    }

    // @Override from BasePanel
    override public function updateDisplay (data :FurniData) :void
    {
        super.updateDisplay(data);

        // ignore furni data - we don't care about which furni is selected,
        // only care about the room itself

        if (_controller.scene != null) {
            _name.text = _controller.scene.getName();
            updateAccessButtons();
            this.enabled = true; // override base changes
        }
    }

    // @Override from superclass
    override protected function createChildren () :void
    {
        super.createChildren();

        // container for name and lock buttons
        var box :HBox = new HBox();
        addChild(box);
        
        _name = new TextInput();
        _name.percentWidth = 100;
        box.addChild(_name);
        
        _buttonbar = new ToggleButtonBar();
        _buttonbar.styleName = "roomEditAccessButtons";
        box.addChild(_buttonbar);
        
        addChild(makePanelButtons());
    }

    // @Override from superclass
    override protected function childrenCreated () :void
    {
        super.childrenCreated();

        _buttonbar.addEventListener(ItemClickEvent.ITEM_CLICK, applyHandler);
        _name.addEventListener(Event.CHANGE, changedHandler);
        _name.addEventListener(FlexEvent.ENTER, applyHandler);
    }

    // @Override from BasePanel
    override protected function applyChanges () :void
    {
        super.applyChanges();

        var model :MsoySceneModel = _controller.scene.getSceneModel() as MsoySceneModel;
        if (_name.text != model.name || _buttonbar.selectedIndex != model.accessControl) {
            // configure an update
            var newscene :MsoyScene = _controller.scene.clone() as MsoyScene;
            var newmodel :MsoySceneModel = newscene.getSceneModel() as MsoySceneModel;
            newmodel.name = _name.text;
            newmodel.accessControl = _buttonbar.selectedIndex;
            _controller.updateScene(_controller.scene, newscene);
        }
    }

    protected function updateAccessButtons () :void
    {
        if (_controller.scene == null) {
            return; // nothing to do
        }

        var model :MsoySceneModel = _controller.scene.getSceneModel() as MsoySceneModel;
        if (_buttonbar.dataProvider == null) {
            var defs :Array = new Array();
            for each (var ii :int in [ MsoySceneModel.ACCESS_EVERYONE,
                                       MsoySceneModel.ACCESS_OWNER_AND_FRIENDS,
                                       MsoySceneModel.ACCESS_OWNER_ONLY ]) {
                var tip :String = Msgs.EDITING.get("m.access_" + model.ownerType + "_" + ii);
                defs.push({ id: ii, icon: ICONS[ii], toolTip: tip });
            }
            _buttonbar.dataProvider = defs;
        }
        _buttonbar.selectedIndex = model.accessControl;
    }
    
    protected var _name :TextInput;
    protected var _buttonbar :ToggleButtonBar;
    
    [Embed(source="../../../../../../../../rsrc/media/skins/button/furniedit/button_access_everyone.png")]
    protected static const ICON_EVERYONE :Class;
    [Embed(source="../../../../../../../../rsrc/media/skins/button/furniedit/button_access_owner_and_friends.png")]
    protected static const ICON_OWNER_FRIENDS :Class;
    [Embed(source="../../../../../../../../rsrc/media/skins/button/furniedit/button_access_owner_only.png")]
    protected static const ICON_OWNER :Class;
    protected static const ICONS :Array = [ ICON_EVERYONE, ICON_OWNER_FRIENDS, ICON_OWNER ];
    
}

}
