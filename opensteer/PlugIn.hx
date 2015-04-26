// ----------------------------------------------------------------------------
//
// PaperSteer - Papervision3D Port of OpenSteer
// Port by Mohammad Haseeb aka M.H.A.Q.S.
// http://www.tabinda.net
// AS3 Refactor by Andras Csizmadia <andras@vpmedia.eu> (No PV3D dependency)
// HaXe Port by Andras Csizmadia <andras@vpmedia.eu> 
//
// OpenSteer -- Steering Behaviors for Autonomous Characters
//
// Copyright (c) 2002-2003, Sony Computer Entertainment America
// Original author: Craig Reynolds <craig_reynolds@playstation.sony.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//
// ----------------------------------------------------------------------------
package opensteer;

// was an abstract base class
class PlugIn implements IPlugIn 
{
    public var Name(get, null) : String;
    public var Vehicles(get, null) : Array<IVehicle>;
    public var SelectionOrderSortKey(get, null) : Float;
    public var RequestInitialSelection(get, null) : Bool;

    // This array stores a list of all PlugIns.  It is manipulated by the
        // constructor and destructor, and used in findByName and applyToAll.
   static var registry : Array<PlugIn> = new Array<PlugIn>();
    static inline var totalSizeOfRegistry : Int = 1000;
    static var itemsInRegistry : Int = 0;
    var name : String;
    /**

     * Open Plugins and intialize any variables

     */    public function Open() : Void {
    }

    /**

     * Updates the plugin and objects related to it

     * @param    currentTime Current RealTime Clock Tick

     * @param    elapsedTime Elapsed Time since last Tick

     */    public function Update(currentTime : Float, elapsedTime : Float) : Void {
    }

    /**

     * Redraw the plugin and objects related to it

     * @param    currentTime Current RealTime Clock Tick

     * @param    elapsedTime Elapsed Time since last Tick

     */    public function Redraw(currentTime : Float, elapsedTime : Float) : Void {
    }

    /**

     * Close the plugin and destroy objects

     */    public function Close() : Void {
    }

    /**

     * Return the name of the plugin

     */    public function get_Name() : String {
        return name;
    }

    /**

     * Return all Vehicles of the selected Plugin

     */    public function get_Vehicles() : Array<IVehicle> {
        return new Array<IVehicle>();
    }

    /**

     * Prototypes for function pointers used with PlugIns

     * @param    clientObject 

     */    public function PlugInCallBackFunction(args:Array<Dynamic>) : Void {
    }

    public function VoidCallBackFunction() : Void {
    }

    public function TimestepCallBackFunction(currentTime : Float, elapsedTime : Float) : Void {
    }

    /**

     * Constructor

     */    public function new() {
        // save this new instance in the registry
        AddToRegistry();
    }

    /**

     * Default reset method is to do a close then an open

     */    public function Reset() : Void {
        Close();
        Open();
    }

    /**

     * Default sort key (after the "built ins")

     */    public function get_SelectionOrderSortKey() : Float {
        return 1.0;
    }

    /**

     * Default is to NOT request to be initially selected

     */    public function get_RequestInitialSelection() : Bool {
        return false;
    }

    /**

     * Default function key handler: ignore all

     * @param    key

     */    public function HandleFunctionKeys(key : Int) : Void {
    }

    /**

     * Default "mini help": print nothing

     */    public function PrintMiniHelpForFunctionKeys() : Void {
    }

    /**

     * Returns pointer to the next PlugIn in "selection order"

     * @return Plugin Instance

     */    public function Next() : PlugIn {
        var i : Int = 0;
        while(i < itemsInRegistry) {
            if(this == registry[i])  {
                var atEnd : Bool = (i == (itemsInRegistry - 1));
                return registry[(atEnd) ? 0 : i + 1];
            }
            i++;
        }
        return null;
    }

    /**

     * Format instance to characters for printing to stream

     * @return Plugin Name

     */    public function ToString() : String {
        return Std.string("<PlugIn \"" + Name + "\">");
    }

    // CLASS FUNCTIONS
        /**

     * Search the class registry for a Plugin with the given name

     * @param    Name Fint plugin by Name

     * @return  Plugin instance

     */    static public function FindByName(Name : String) : IPlugIn {
        if(Name == null || Name == "")  {
            var i : Int = 0;
            while(i < itemsInRegistry) {
                var pi : PlugIn = registry[i];
                var s : String = pi.Name;
                if((s == null || s == "") && Name == s)  {
                    return pi;
                }
                i++;
            }
        }
        return null;
    }

    /**

     * Apply a given function to all PlugIns in the class registry

     * @param    f Function to apply to all Items

     */    static public function ApplyToAll(func : Void->Void) : Void {
        var i : Int = 0;
        while(i < itemsInRegistry) {
            
            /*func.call(null, {
                plugin : registry[i]

            });*/
            Reflect.callMethod(null, func, [{plugin : registry[i]}]);
            
            i++;
        }
    }

    /**

     * Sort PlugIn registry by "selection order"

     */    static public function SortBySelectionOrder() : Void {
        // I know, I know, just what the world needs:
        // another inline shell sort implementation...
        // starting at each of the first n-1 elements of the array
        var i : Int = 0;
        while(i < itemsInRegistry - 1) {
            // scan over subsequent pairs, swapping if larger value is first
            var j : Int = i + 1;
            while(j < itemsInRegistry) {
                var iKey : Float = registry[i].SelectionOrderSortKey;
                var jKey : Float = registry[j].SelectionOrderSortKey;
                if(iKey > jKey)  {
                    var temporary : PlugIn = registry[i];
                    registry[i] = registry[j];
                    registry[j] = temporary;
                }
                j++;
            }
;
            i++;
        }
;
    }

    /**

     * Returns pointer to default PlugIn (currently, first in registry)

     * @return Pointer to default PlugIn

     */    static public function FindDefault() : PlugIn {
        // return NULL if no PlugIns exist
        if(itemsInRegistry == 0)  {
            return null;
        }
;
        // otherwise, return the first PlugIn that requests initial selection
        var i : Int = 0;
        while(i < itemsInRegistry) {
            if(registry[i].RequestInitialSelection)  {
                return registry[i];
            }
            i++;
        }
;
        // otherwise, return the "first" PlugIn (in "selection order")
        return registry[0];
    }

    /**

     * Save this instance in the class's registry of instances

     */    function AddToRegistry() : Void {
        // save this instance in the registry
        registry[itemsInRegistry++] = this;
    }

}

