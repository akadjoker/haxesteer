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

/// <summary>
/// Pathway: a pure virtual base class for an abstract pathway in space, as for
/// example would be used in path following.
/// </summary>
// was an abstract base class
class Pathway {

    // Given an arbitrary point ("A"), returns the nearest point ("P") on
        // this path.  Also returns, via output arguments, the path tangent at
        // P and a measure of how far A is outside the Pathway's "tube".  Note
        // that a negative distance indicates A is inside the Pathway.
        public function MapPointToPath(point : Vec3, tangent : Vec3, outside : Float) : Array<Dynamic> {
        return new Array<Dynamic>();
    }

    // given a distance along the path, convert it to a point on the path
        public function MapPathDistanceToPoint(pathDistance : Float) : Vec3 {
        return new Vec3();
    }

    // Given an arbitrary point, convert it to a distance along the path.
        public function MapPointToPathDistance(point : Vec3) : Float {
        return 0;
    }

    // is the given point inside the path tube?
        public function IsInsidePath(point : Vec3) : Bool {
        var outside : Float=0;
        var tangent : Vec3=new Vec3();
        var temp : Array<Dynamic> = MapPointToPath(point, tangent, outside);
        tangent = temp[1];
        outside = temp[2];
        return outside < 0;
    }

    // how far outside path tube is the given point?  (negative is inside)
        public function HowFarOutsidePath(point : Vec3) : Float {
        var outside : Float=0;
        var tangent : Vec3=new Vec3();
        var temp : Array<Dynamic> = MapPointToPath(point, tangent, outside);
        tangent = temp[1];
        outside = temp[2];
        return outside;
    }


    public function new() {
    }
}

