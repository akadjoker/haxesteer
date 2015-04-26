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



class Vec3 {

    //*********************************************************************************
        // Variables
        //*********************************************************************************
        // Coordinate Points in 3D Vector Space
    public var x : Float;
    public var y : Float;
    public var z : Float;
    // Special points in Vector Space
        static public var Zero : Vec3 = new Vec3(0, 0, 0);
    static public var Up : Vec3 = new Vec3(0, 1, 0);
    static public var Left : Vec3 = new Vec3(-1, 0, 0);
    // Right Handed
        static public var Right : Vec3 = new Vec3(1, 0, 0);
    // Right Handed
        static public var Forward : Vec3 = new Vec3(0, 0, -1);
    // Right Handed
        static public var Backward : Vec3 = new Vec3(0, 0, 1);
    // Right Handed
        static public var Down : Vec3 = new Vec3(0, -1, 0);
    static public var UnitX : Vec3 = new Vec3(1, 0, 0);
    static public var UnitY : Vec3 = new Vec3(0, 1, 0);
    static public var UnitZ : Vec3 = new Vec3(0, 0, 1);
    static public var UnitVector : Vec3 = new Vec3(1, 1, 1);
    //*********************************************************************************
        // Constructors
        //*********************************************************************************
        // A mutliple constructor handler
        public function new(_x : Float = 0.0, _y : Float = 0.0, _z : Float = 0.0) {
        x = 0.0;
        y = 0.0;
        z = 0.0;
        x = _x;
        y = _y;
        z = _z;
    }

    // This serves as an alternate Constructor
        // Returns a new Vec3 instance
        public function Constructor() : Vec3 {
        return new Vec3(this.x, this.y, this.z);
    }

    // Serves as a Copy Constructor
        public function CopyConstructor(v : Vec3) : Vec3 {
        return new Vec3(v.x, v.y, v.z);
    }

    // vector addition
        static public function VectorAddition(lvec : Vec3, rvec : Vec3) : Vec3 {
        return new Vec3(lvec.x + rvec.x, lvec.y + rvec.y, lvec.z + rvec.z);
    }

    // vector subtraction
        static public function VectorSubtraction(lvec : Vec3, rvec : Vec3) : Vec3 {
        return new Vec3(lvec.x - rvec.x, lvec.y - rvec.y, lvec.z - rvec.z);
    }

    // unary minus
        static public function Negate(vec : Vec3) : Vec3 {
        return new Vec3(-vec.x, -vec.y, -vec.z);
    }

    // vector times scalar product(scale length of vector times argument)
        static public function ScalarMultiplication(scaleFactor : Float, vec : Vec3) : Vec3 {
        return new Vec3(vec.x * scaleFactor, vec.y * scaleFactor, vec.z * scaleFactor);
    }

    // vector divided by a scalar(divide length of vector by argument)
        static public function ScalarDivision(vec : Vec3, divider : Float) : Vec3 {
        return new Vec3(vec.x / divider, vec.y / divider, vec.z / divider);
    }

    // dot product
        public function DotProduct(vec : Vec3) : Float {
        return (this.x * vec.x) + (this.y * vec.y) + (this.z * vec.z);
    }

    // length
        public function Magnitude() : Float {
        return Math.sqrt(SquaredMagnitude());
    }

    // length squared
        public function SquaredMagnitude() : Float {
        return DotProduct(this);
    }

    //normalize: returns normalized version(parallel to this, length = 1)
        public function Normalize() : Void {
        // Technique 1: Skips divide if lenth is zero
        // skip divide if length is zero
        //var len:Number = Magnitude();
        //return (len>0) ? ScalarDivision(this,len) : (this);
        // Technique 2: Skips divide if length is 0 or 1 AND uses Multiply instead if division
        // Multiply is way faster than division.
        var mag : Float = Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
        if(mag != 0 && mag != 1)  {
            mag = 1 / mag;
            this.x *= mag;
            this.y *= mag;
            this.z *= mag;
        }
    }

    // normalize: returns normalized version(parallel to this, length = 1)
        /*public function fNormalize():Number

    {

    var fLength:Number=Number(Math.sqrt(x * x + y * y + z * z));



    // Will also work for zero-sized vectors, but will change nothing

    if (fLength > 1e-08)

    {

    var fInvLength:Number=1.0 / fLength;

    x*= fInvLength;

    y*= fInvLength;

    z*= fInvLength;

    }



    return fLength;

    }*/    static public function CrossProduct(lvec : Vec3, rvec : Vec3) : Vec3 {
        return new Vec3((lvec.y * rvec.z) - (lvec.z * rvec.y), (lvec.z * rvec.x) - (lvec.x * rvec.z), (lvec.x * rvec.y) - (lvec.y * rvec.x));
    }

    // set XYZ coordinates to given three floats
        public function set_XYZ(x : Float, y : Float, z : Float) : Vec3 {
        this.x = x;
        this.y = y;
        this.z = z;
        return this;
    }

    // equality/inequality
        static public function isEqual(lvec : Vec3, rvec : Vec3) : Bool {
        return (lvec.x == rvec.x) && (lvec.y == rvec.y) && (lvec.z == rvec.z);
    }

    static public function isNotEqual(lvec : Vec3, rvec : Vec3) : Bool {
        return (lvec.x != rvec.x) && (lvec.y != rvec.y) && (lvec.z != rvec.z);
    }

    static public function Distance(lvec : Vec3, rvec : Vec3) : Float {
        return VectorSubtraction(lvec, rvec).Magnitude();
    }

    // utility member functions used in OpenSteer
        // return component of vector parallel to a unit basis vector
        // IMPORTANT NOTE: assumes "basis" has unit magnitude (length == 1)
        public function ParallelComponent(unitBasis : Vec3) : Vec3 {
        var projection : Float = DotProduct(unitBasis);
        return ScalarMultiplication(projection, unitBasis);
    }

    // return component of vector perpendicular to a unit basis vector
        // IMPORTANT NOTE: assumes "basis" has unit magnitude(length==1)
        public function PerpendicularComponent(unitBasis : Vec3) : Vec3 {
        return VectorSubtraction(this, ParallelComponent(unitBasis));
    }

    // clamps the length of a given vector to maxLength.  If the vector is
        // shorter its value is returned unaltered, if the vector is longer
        // the value returned has length of maxLength and is paralle to the
        // original input.
        public function TruncateLength(maxLength : Float) : Vec3 {
        var maxLengthSquared : Float = maxLength * maxLength;
        var vecLengthSquared : Float = SquaredMagnitude();
        if(vecLengthSquared <= maxLengthSquared) 
            return this
        else return ScalarMultiplication((maxLength / Math.sqrt(vecLengthSquared)), this);
    }

    // forces a 3d position onto the XZ (aka y=0) plane
        //FIXME: Misleading name
        public function SetYToZero() : Vec3 {
        return new Vec3(x, 0, z);
    }

    // rotate this vector about the global Y (up) axis by the given angle
        // takes angle:Number, sin:Number, cos:Number
        public function RotateAboutGlobalY(args:Array<Dynamic>) : Vec3 {
        //trace("Vec3.RotateAboutGlobalY",args[0] is Number, args[1] is Number, args[2] is Number);
        if(args.length == 3)  {
            // is both are zero, they have not be initialized yet
            if(args[1] == 0 && args[2] == 0)  {
                args[1] = Math.sin(args[0]);
                args[2] = Math.cos(args[0]);
            }
;
            return new Vec3((this.x * args[2]) + (this.z * args[1]), this.y, (this.z * args[2]) - (this.x * args[1]));
        }

        else  {
            var s : Float = Math.sin(args[0]);
            var c : Float = Math.cos(args[0]);
            return new Vec3((this.x * c) + (this.z * s), (this.y), (this.z * c) - (this.z * s));
        }
;
    }

    // if this position is outside sphere, push it back in by one diameter
        public function SphericalWraparound(center : Vec3, radius : Float) : Vec3 {
        var offset : Vec3 = VectorSubtraction(this, center);
        var r : Float = offset.Magnitude();
        if(r > radius) 
            return VectorAddition(this, ScalarMultiplication(radius * -2, ScalarMultiplication(1 / r, offset)))
        else return this;
    }


        // ----------------------------------------------------------------------------
        // Returns a position randomly distributed on a disk of unit radius
        // on the XZ (Y=0) plane, centered at the origin.  Orientation will be
        // random and length will range between 0 and 1
        static public function RandomVectorOnUnitRadiusXZDisk() : Vec3 {
        var v : Vec3 = new Vec3();
        do {
            v.set_XYZ((Math.random() * 2) - 1, 0, (Math.random() * 2) - 1);
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
            v.set_XYZ((Math.random() * 2) - 1, (Math.random() * 2) - 1, (Math.random() * 2) - 1);
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
        temp.SetYToZero();
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
        var direction : Vec3 = ScalarMultiplication(1 / sourceLength, source);
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

        else  {
            // source vector is already outside the cone, just return it
            if(cosineOfSourceAngle <= cosineOfConeAngle)  {
                return source;
            }
;
        }
;
        // find the portion of "source" that is perpendicular to "basis"
        var perp : Vec3 = source.PerpendicularComponent(basis);
        perp.Normalize();
        // normalize that perpendicular
        var unitPerp : Vec3 = perp;
        // construct a new vector whose length equals the source vector,
        // and lies on the intersection of a plane (formed the source and
        // basis vectors) and a cone (whose axis is "basis" and whose
        // angle corresponds to cosineOfConeAngle)
        var perpDist : Float = Math.sqrt(1 - (cosineOfConeAngle * cosineOfConeAngle));
        var c0 : Vec3 = ScalarMultiplication(cosineOfConeAngle, basis);
        var c1 : Vec3 = ScalarMultiplication(perpDist, unitPerp);
        return ScalarMultiplication(sourceLength, VectorAddition(c0, c1));
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
        var offset : Vec3 = VectorSubtraction(point, lineOrigin);
        var perp : Vec3 = offset.PerpendicularComponent(lineUnitTangent);
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
        var i : Vec3 = new Vec3(1, 0, 0);
        var j : Vec3 = new Vec3(0, 1, 0);
        var k : Vec3 = new Vec3(0, 0, 1);
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
        result = CrossProduct(direction, quasiPerp);
        return result;
    }

    // Prints the Vector
        public function toString() : String {
        return ("x= " + x + " y= " + y + " z= " + z);
    }

}

