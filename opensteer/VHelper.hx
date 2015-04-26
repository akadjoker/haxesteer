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

class VHelper {

    // return component of vector parallel to a unit basis vector
        // IMPORTANT NOTE: assumes "basis" has unit magnitude (length == 1)
        static public function ParallelComponent(vector : Vec3, unitBasis : Vec3) : Vec3 {
        var projection : Float = vector.DotProduct(unitBasis);
        return Vec3.ScalarMultiplication(projection, unitBasis);
    }

    // return component of vector perpendicular to a unit basis vector
        // IMPORTANT NOTE: assumes "basis" has unit magnitude(length==1)
        static public function PerpendicularComponent(vector : Vec3, unitBasis : Vec3) : Vec3 {
        return Vec3.VectorSubtraction(vector, ParallelComponent(vector, unitBasis));
    }

    // clamps the length of a given vector to maxLength.  If the vector is
        // shorter its value is returned unaltered, if the vector is longer
        // the value returned has length of maxLength and is paralle to the
        // original input.
        static public function TruncateLength(vector : Vec3, maxLength : Float) : Vec3 {
        var maxLengthSquared : Float = maxLength * maxLength;
        var vecLengthSquared : Float = vector.SquaredMagnitude();
        if(vecLengthSquared <= maxLengthSquared) 
            return vector
        else return Vec3.ScalarMultiplication((maxLength / Math.sqrt(vecLengthSquared)), vector);
    }

    // forces a 3d position onto the XZ (aka y=0) plane
        static public function SetYtoZero(vector : Vec3) : Vec3 {
        return new Vec3(vector.x, 0, vector.z);
    }

    // rotate this vector about the global Y (up) axis by the given angle
        // receives vector:Vec3, angle:Number, sin:Number, cos:Number
        static public function RotateAboutGlobalY(args:Array<Dynamic>) : Array<Dynamic> {
        //trace("VHelper.RotateAboutGlobalY",args[0] is Vec3, args[1] is Number, args[2] is Number, args[3] is Number);
        var vec : Vec3;
        var angle : Float;
        var sin : Float;
        var cos : Float;
        if(args.length == 4)  {
            vec = args[0];
            angle = args[1];
            sin = args[2];
            cos = args[3];
            // is both are zero, they have not been initialized yet
            if(sin == 0 && cos == 0)  {
                sin = Math.sin(angle);
                cos = Math.cos(angle);
            }
;
            var temp : Array<Dynamic> = new Array<Dynamic>();
            temp.push(sin);
            temp.push(cos);
            temp.push(new Vec3((vec.x * cos) + (vec.z * sin), (vec.y), (vec.z * cos) - (vec.x * sin)));
            return temp;
        }

        else  {
            vec = args[0];
            angle = args[1];
            sin = Math.sin(angle);
            cos = Math.cos(angle);
            var temp:Array<Dynamic> = new Array();
            temp.push(sin);
            temp.push(cos);
            temp.push(new Vec3((vec.x * cos) + (vec.z * sin), (vec.y), (vec.z * cos) - (vec.x * sin)));
            return temp;
        }

    }

    // if this position is outside sphere, push it back in by one diameter
        static public function SphericalWrapAround(vector : Vec3, center : Vec3, radius : Float) : Vec3 {
        var offset : Vec3 = Vec3.VectorSubtraction(vector, center);
        var r : Float = offset.Magnitude();
        if(r > radius) 
            return Vec3.VectorAddition(vector, Vec3.ScalarMultiplication(radius * -2, (Vec3.ScalarMultiplication(1 / r, offset))))
        else return vector;
    }

    // ----------------------------------------------------------------------------
        // Returns a position randomly distributed on a disk of unit radius
        // on the XZ (Y=0) plane, centered at the origin.  Orientation will be
        // random and length will range between 0 and 1
        static public function RandomVectorOnUnitRadiusXZDisk() : Vec3 {
        var v : Vec3 = new Vec3();
        do {
            v.x = (Math.random() * 2) - 1;
            v.y = 0;
            v.z = (Math.random() * 2) - 1;
        }
while((v.Magnitude() >= 1));
        return v;
    }

    // Returns a position randomly distributed inside a sphere of unit radius
        // centered at the origin.  Orientation will be random and length will range
        // between 0 and 1
        static public function RandomVectorInUnitRadiusSphere() : Vec3 {
        var v : Vec3 = new Vec3();
        do {
            v.x = (Math.random() * 2) - 1;
            v.y = (Math.random() * 2) - 1;
            v.z = (Math.random() * 2) - 1;
        }
while((v.Magnitude() >= 1));
        return v;
    }

    // ----------------------------------------------------------------------------
        // Returns a position randomly distributed on the surface of a sphere
        // of unit radius centered at the origin.  Orientation will be random
        // and length will be 1
        static public function RandomUnitVector() : Vec3 {
        var temp : Vec3 = RandomVectorInUnitRadiusSphere();
        temp.Normalize();
        return temp;
    }

    // ----------------------------------------------------------------------------
        // Returns a position randomly distributed on a circle of unit radius
        // on the XZ (Y=0) plane, centered at the origin.  Orientation will be
        // random and length will be 1
        static public function RandomUnitVectorOnXZPlane() : Vec3 {
        var temp : Vec3 = RandomVectorInUnitRadiusSphere();
        temp.y = 0;
        temp.Normalize();
        return temp;
    }

    // ----------------------------------------------------------------------------
        // used by limitMaxDeviationAngle / limitMinDeviationAngle below
        static public function LimitDeviationAngleUtility(insideOrOutside : Bool, source : Vec3, cosineOfConeAngle : Float, basis : Vec3) : Vec3 {
        // immediately return zero length input vectors
        var sourceLength : Float = source.Magnitude();
        if(sourceLength == 0)  {
            return source;
        }
        // measure the angular diviation of "source" from "basis"
        var direction : Vec3 = Vec3.ScalarMultiplication(1 / sourceLength, source);
        var cosineOfSourceAngle : Float = direction.DotProduct(basis);
        // Simply return "source" if it already meets the angle criteria.
        // (note: we hope this top "if" gets compiled out since the flag
        // is a constant when the function is inlined into its caller)
        if(insideOrOutside)  {
            // source vector is already inside the cone, just return it
            if(cosineOfSourceAngle >= cosineOfConeAngle)  {
                return source;
            }
;
        }

        else if(cosineOfSourceAngle <= cosineOfConeAngle)  {
            return source;
        }
;
        // find the portion of "source" that is perpendicular to "basis"
        var perp : Vec3 = PerpendicularComponent(source, basis);
        // normalize that perpendicular
        var unitPerp : Vec3 = perp;
        unitPerp.Normalize();
        // construct a new vector whose length equals the source vector,
        // and lies on the intersection of a plane (formed the source and
        // basis vectors) and a cone (whose axis is "basis" and whose
        // angle corresponds to cosineOfConeAngle)
        var perpDist : Float = Math.sqrt(1 - (cosineOfConeAngle * cosineOfConeAngle));
        var c0 : Vec3 = Vec3.ScalarMultiplication(cosineOfConeAngle, basis);
        var c1 : Vec3 = Vec3.ScalarMultiplication(perpDist, unitPerp);
        return Vec3.ScalarMultiplication(sourceLength, Vec3.VectorAddition(c0, c1));
    }

    // ----------------------------------------------------------------------------
        // Enforce an upper bound on the angle by which a given arbitrary vector
        // diviates from a given reference direction (specified by a unit basis
        // vector).  The effect is to clip the "source" vector to be inside a cone
        // defined by the basis and an angle.
        static public function LimitMaxDeviationAngle(source : Vec3, cosineOfConeAngle : Float, basis : Vec3) : Vec3 {
        return LimitDeviationAngleUtility(true, // force source INSIDE cone
        source, cosineOfConeAngle, basis);
    }

    // ----------------------------------------------------------------------------
        // Enforce a lower bound on the angle by which a given arbitrary vector
        // diviates from a given reference direction (specified by a unit basis
        // vector).  The effect is to clip the "source" vector to be outside a cone
        // defined by the basis and an angle.
        static public function LimitMinDeviationAngle(source : Vec3, cosineOfConeAngle : Float, basis : Vec3) : Vec3 {
        return LimitDeviationAngleUtility(false, // force source OUTSIDE cone
        source, cosineOfConeAngle, basis);
    }

    // ----------------------------------------------------------------------------
        // Returns the distance between a point and a line.  The line is defined in
        // terms of a point on the line ("lineOrigin") and a UNIT vector parallel to
        // the line ("lineUnitTangent")
        static public function DistanceFromLine(point : Vec3, lineOrigin : Vec3, lineUnitTangent : Vec3) : Float {
        var offset : Vec3 = Vec3.VectorSubtraction(point, lineOrigin);
        var perp : Vec3 = VHelper.PerpendicularComponent(offset, lineUnitTangent);
        return perp.Magnitude();
    }

    // ----------------------------------------------------------------------------
        // given a vector, return a vector perpendicular to it (note that this
        // arbitrarily selects one of the infinitude of perpendicular vectors)
        static public function FindPerpendicularIn3d(direction : Vec3) : Vec3 {
        // to be filled in:
        var quasiPerp : Vec3;
        // a direction which is "almost perpendicular"
        var result : Vec3 = new Vec3();
        // the computed perpendicular to be returned
        // three mutually perpendicular basis vectors
        var i : Vec3 = Vec3.Forward;
        var j : Vec3 = Vec3.Up;
        var k : Vec3 = Vec3.Backward;
        // measure the projection of "direction" onto each of the axes
        var id : Float = i.DotProduct(direction);
        var jd : Float = j.DotProduct(direction);
        var kd : Float = k.DotProduct(direction);
        // set quasiPerp to the basis which is least parallel to "direction"
        if((id <= jd) && (id <= kd))  {
            quasiPerp = i;
        }

        else  {
            if((jd <= id) && (jd <= kd)) 
                quasiPerp = j
            else // projection onto j was the smallest
            quasiPerp = k;
        }
;
        // return the cross product (direction x quasiPerp)
        // which is guaranteed to be perpendicular to both of them
        result = new Vec3((direction.y * quasiPerp.z) - (direction.z * quasiPerp.y), (direction.z * quasiPerp.x) - (direction.x * quasiPerp.z), (direction.x * quasiPerp.y) - (direction.y * quasiPerp.x));
        return result;
    }


    public function new() {
    }
}

