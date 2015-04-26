// ----------------------------------------------------------------------------
// PaperSteer - Papervision3D Port of OpenSteer
// Port by Mohammad Haseeb aka M.H.A.Q.S.
// http://www.tabinda.net
// AS3 Refactor by Andras Csizmadia <andras@vpmedia.eu> (No PV3D dependency)
// HaXe Port by Andras Csizmadia <andras@vpmedia.eu> 
// HaXe3 Port by Luis Santos AKA DJOKER <djokertheripper@gmail.com>  https://djokergames.wordpress.com/ (No  dependency)
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
// ----------------------------------------------------------------------------
package opensteer;

interface IPlugIn {
    public var Name(get, null) : String;
    public var SelectionOrderSortKey(get, null) : Float;
    public var RequestInitialSelection(get, null) : Bool;
    public var Vehicles(get, null) : Array<IVehicle>;

    // generic PlugIn actions: open, update, redraw, close and reset
    function Open() : Void;
    function Update(currentTime : Float, elapsedTime : Float) : Void;
    function Redraw(currentTime : Float, elapsedTime : Float) : Void;
    function Close() : Void;
    function Reset() : Void;
    // return a pointer to this instance's character string name
    public    function get_Name() : String;
    // numeric sort key used to establish user-visible PlugIn ordering
        // ("built ins" have keys greater than 0 and less than 1)
	public   function get_SelectionOrderSortKey() : Float;
    // allows a PlugIn to nominate itself as OpenSteerDemo's initially selected
        // (default) PlugIn, which is otherwise the first in "selection order"
	public function get_RequestInitialSelection() : Bool;
    // handle function keys (which are reserved by SterTest for PlugIns)
        function HandleFunctionKeys(key : Int) : Void;
    // print "mini help" documenting function keys handled by this PlugIn
        function PrintMiniHelpForFunctionKeys() : Void;
    // return an AVGroup (an STL vector of AbstractVehicle pointers) of
        // all vehicles(/agents/characters) defined by the PlugIn
        public function get_Vehicles() : Array<IVehicle>;
}

