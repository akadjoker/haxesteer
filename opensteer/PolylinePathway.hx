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
/// PolylinePathway: a simple implementation of the Pathway protocol.  The path
/// is a "polyline" a series of line segments between specified points.  A
/// radius defines a volume for the path which is the union of a sphere at each
/// point and a cylinder along each segment.
/// </summary>
class PolylinePathway extends Pathway 
{
    public var TotalPathLength(get, null) : Float;

    public var pointCount : Int;
    public var points : Array<Vec3>;
    public var radius : Float;
    public var cyclic : Bool;
    // XXX removed the "private" because it interfered with derived
        // XXX classes later this should all be rewritten and cleaned up
        // private:
        // xxx shouldn't these 5 just be local variables?
        // xxx or are they used to pass secret messages between calls?
        // xxx seems like a bad design
        var segmentLength : Float;
    var segmentProjection : Float;
    var local : Vec3;
    var chosen : Vec3;
    var segmentNormal : Vec3;
    var lengths : Array<Float>;
    var normals : Array<Vec3>;
    var totalPathLength : Float;
    // construct a PolylinePathway given the number of points (vertices),
        // an array of points, and a path radius.
        // takes _pointCount:int,_points:Array,_radius:Float,_cyclic:Boolean
       
		public function new(args:Array<Dynamic>) 
		{
    super();
        //trace("PolylinePathway.constructor",args[0] is int, args[1] is Vector.<Vec3>, args[2] is Float,args[3] is Boolean);
        if(args.length == 4)  {
            Initialize(args[0], args[1], args[2], args[3]);
        }

        else { };
    }

    // utility for constructors in derived classes
        public function Initialize(_pointCount : Int, _points : Array<Vec3>, _radius : Float, _cyclic : Bool) : Void {
        // set data members, allocate arrays
        radius = _radius + 0.0;
        cyclic = _cyclic;
        pointCount = _pointCount;
        totalPathLength = 0.0;
        if(cyclic)  {
            pointCount++;
        }
        lengths = new Array<Float>();
        points = new Array<Vec3>();
        normals = new Array<Vec3>();
        // loop over all points
        var i : Int = 0;
        while(i < pointCount) {
            // copy in point locations, closing cycle when appropriate
            var closeCycle : Bool = cyclic && i == pointCount - 1;
            var j : Int = (closeCycle) ? 0 : i;
            points[i] = _points[j];
            // for the end of each segment
            if(i > 0)  {
                // compute the segment length
                normals[i] = Vec3.VectorSubtraction(points[i], points[i - 1]);
                lengths[i] = normals[i].Magnitude();
                // find the normalized vector parallel to the segment
                normals[i] = Vec3.ScalarMultiplication((1 / lengths[i]), normals[i]);
                // keep running total of segment lengths
                totalPathLength += lengths[i];
            }
;
            i++;
        }
;
    }

    // Given an arbitrary point ("A"), returns the nearest point ("P") on
        // this path.  Also returns, via output arguments, the path tangent at
        // P and a measure of how far A is outside the Pathway's "tube".  Note
        // that a negative distance indicates A is inside the Pathway.
        override public function MapPointToPath(point : Vec3, tangent : Vec3, outside : Float) : Array<Dynamic> {
        var d : Float;
        var minDistance : Float = Math.POSITIVE_INFINITY;
        var onPath : Vec3 = Vec3.Zero;
        tangent = Vec3.Zero;
        // loop over all segments, find the one nearest to the given point
        var i : Int = 1;
        while(i < pointCount) {
            segmentLength = lengths[i];
            segmentNormal = normals[i];
            d = PointToSegmentDistance(point, points[i - 1], points[i]);
            if(d < minDistance)  {
                minDistance = d;
                onPath = chosen;
                tangent = segmentNormal;
            }
            i++;
        }
;
        // measure how far original point is outside the Pathway's "tube"
        outside = Vec3.Distance(onPath, point) - radius;
        var temp : Array<Dynamic> = new Array<Dynamic>();
        temp[0] = onPath;
        temp[1] = tangent;
        temp[2] = outside;
        // return point on path
        return temp;
    }

    // given an arbitrary point, convert it to a distance along the path
        override public function MapPointToPathDistance(point : Vec3) : Float {
        var d : Float;
        var minDistance : Float = Math.POSITIVE_INFINITY;
        var segmentLengthTotal : Float = 0.0;
        var pathDistance : Float = 0.0;
        var i : Int = 1;
        while(i < pointCount) {
            segmentLength = lengths[i];
            segmentNormal = normals[i];
            d = PointToSegmentDistance(point, points[i - 1], points[i]);
            if(d < minDistance)  {
                minDistance = d;
                pathDistance = segmentLengthTotal + segmentProjection;
            }
            segmentLengthTotal += segmentLength;
            i++;
        }
        // return distance along path of onPath point
        return pathDistance + 0.0;
    }

    // given a distance along the path, convert it to a point on the path
        override public function MapPathDistanceToPoint(pathDistance : Float) : Vec3 {
        // clip or wrap given path distance according to cyclic flag
        var remaining : Float = pathDistance;
        if(cyclic)  {
            remaining = pathDistance % totalPathLength + 0.0;
        }

        else  {
            if(pathDistance < 0)  {
                return points[0];
            }
            if(pathDistance >= totalPathLength)  {
                return points[pointCount - 1];
            }
        }

        // step through segments, subtracting off segment lengths until
        // locating the segment that contains the original pathDistance.
        // Interpolate along that segment to find 3d point value to return.
        var result : Vec3 = Vec3.Zero;
        var i : Int = 1;
        while(i < pointCount) {
            segmentLength = lengths[i];
            if(segmentLength < remaining)  {
                remaining -= segmentLength;
            }

            else  {
                var ratio : Float = (remaining / segmentLength) + 0.0;
                result = Utilities.Interpolate2(ratio, points[i - 1], points[i]);
                break;
            }

            i++;
        }
        return result;
    }

    // utility methods
        // compute minimum distance from a point to a line segment
        public function PointToSegmentDistance(point : Vec3, ep0 : Vec3, ep1 : Vec3) : Float {
        // convert the test point to be "local" to ep0
        local = Vec3.VectorSubtraction(point, ep0);
        // find the projection of "local" onto "segmentNormal"
        segmentProjection = segmentNormal.DotProduct(local);
        // handle boundary cases: when projection is not on segment, the
        // nearest point is one of the endpoints of the segment
        if(segmentProjection < 0)  {
            chosen = ep0;
            segmentProjection = 0;
            return Vec3.Distance(point, ep0);
        }
;
        if(segmentProjection > segmentLength)  {
            chosen = ep1;
            segmentProjection = segmentLength;
            return Vec3.Distance(point, ep1);
        }
        // otherwise nearest point is projection point on segment
        chosen = Vec3.ScalarMultiplication(segmentProjection, segmentNormal);
        chosen = Vec3.VectorAddition(chosen, ep0);
        return Vec3.Distance(point, chosen);
    }

    // assessor for total path length;
        public function get_TotalPathLength() : Float {
        return totalPathLength + 0.0;
    }

}

