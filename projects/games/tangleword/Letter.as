package 
{

import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import mx.core.BitmapAsset;


/**
  Letter is a graphical element that sits on the board. 
  The piece is just a view - it contains no logic.
*/
public class Letter extends Sprite
{
    /** 
        Constructor takes the string to be displayed on the piece,
        piece location (in board-local coordinates), and dimensions.
     */
    public function Letter (game : TangleWord, str : String,
                            x : int, y : int, width : int, height : int)
    {
        this.x = x;
        this.y = y;

        // set background bitmap
        _game = game;
        _background = Resources.makeDefaultEmptySquare ();
        addChild (_background);

        // Make a new text label on top of the bitmap.
        _text = makeNewLabel (width, height);
        addChild (_text);
        setText (str);
    }

    /** Set the letter on this label. We figure out the new position based on mask size. */
    public function setText (str : String) : void
    {
        // poor man's assert...
        if (_background == null || _text == null)
        {
            Log.getLog(this).warning ("expected background and text to be initialized by now");
            return;
        }
                    
        _text.text = str;

        var topMargin : Number = (_background.height - _text.height) / 2;
        _text.y = topMargin;
        _text.x = 0;
        _text.width = _background.width;
    }




    // PRIVATE HELPER FUNCTIONS

    private function makeNewLabel (width : int, height : int) : TextField
    {
        // Create text format
        var format : TextFormat = new TextFormat();
        format.font = "Verdana";
        format.color = uint(0x888899);
        format.size = 42;
        format.bold = true;

        // Create text field
        var t : TextField = new TextField ();
        t.autoSize = TextFieldAutoSize.CENTER;
        t.selectable = false;
        t.defaultTextFormat = format;

        t.width = width;
        t.height = height;
        
        return t;
    }
        
        

    // PRIVATE MEMBERS
    
    /** Text label in front */
    private var _text : TextField;

    /** Pointer to the board piece resource */
    private var _background : BitmapAsset;

    /** Pointer back to the game */
    private var _game : TangleWord;
}


}
