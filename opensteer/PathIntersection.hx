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

// xxx cwr 9-6-02 temporary to support old code
class PathIntersection {

    public var intersect : Bool;
    public var distance : Float;
    public var surfacePoint : Vec3;
    public var surfaceNormal : Vec3;
    public var obstacle : SphericalObstacle;
    public function new(_intersect : Bool = false, _distance : Float = 0, _surfacePoint : Vec3 = null, _surfaceNormal : Vec3 = null, _obstacle : SphericalObstacle = null) {
        intersect = _intersect;
        distance = _distance;
        if(_surfacePoint == null) 
            surfacePoint = new Vec3(0, 0, 0)
        else surfacePoint = _surfacePoint;
        if(_surfaceNormal == null) 
            surfaceNormal = new Vec3(0, 0, 0)
        else surfaceNormal = _surfaceNormal;
        if(_obstacle == null) 
            obstacle = new SphericalObstacle(1,0,0,0)
        else obstacle = _obstacle;
    }

}

