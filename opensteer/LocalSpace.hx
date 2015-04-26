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
/// LocalSpaceMixin is a mixin layer, a class template with a paramterized base
/// class.  Allows "LocalSpace-ness" to be layered on any class.
/// </summary>
class LocalSpace implements ILocalSpace {
    public var Side(get, set) : Vec3;
    public var Up(get, set) : Vec3;
    public var Forward(get, set) : Vec3;
    public var Position(get, set) : Vec3;
    public var IsRightHanded(get, null) : Bool;

    // transformation as three orthonormal unit basis vectors and the
        // origin of the local space.  These correspond to the "rows" of
        // a 3x4 transformation matrix with [0 0 0 1] as the final column
        var side : Vec3;
    // side-pointing unit basis vector
        var up : Vec3;
    // upward-pointing unit basis vector
        var forward : Vec3;
    // forward-pointing unit basis vector
        var position : Vec3;
    // origin of local space
        /// <summary>
        /// Gets or sets the side.
        /// </summary>
    public function get_Side() : Vec3 
	{
        return side;
    }

    public function set_Side(val : Vec3) : Vec3 {
        side = val;
        return val;
    }

    /// <summary>
        /// Gets or sets the up.
        /// </summary>
    public function get_Up() : Vec3 
		{
        return up;
    }

    public function set_Up(val : Vec3) : Vec3 {
        up = val;
        return val;
    }

    /// <summary>
        /// Gets or sets the forward.
        /// </summary>
        public function get_Forward() : Vec3 {
        return forward;
    }

    public function set_Forward(val : Vec3) : Vec3 {
        forward = val;
        return val;
    }

    /// <summary>
        /// Gets or sets the position.
        /// </summary>
        public function get_Position() : Vec3 {
        return position;
    }

    public function set_Position(val : Vec3) : Vec3 {
        position = val;
        return val;
    }

    public function Set_Up(x : Float, y : Float, z : Float) : Vec3 {
        up.x = x;
        up.y = y;
        up.z = z;
        return up;
    }

    public function SetForward(x : Float, y : Float, z : Float) : Vec3 {
        forward.x = x;
        forward.y = y;
        forward.z = z;
        return forward;
    }

    public function SetPosition(x : Float, y : Float, z : Float) : Vec3 {
        position.x = x;
        position.y = y;
        position.z = z;
        return position;
    }

    // ------------------------------------------------------------------------
        // Global compile-time switch to control handedness/chirality: should
        // LocalSpace use a left- or right-handed coordinate system?  This can be
        // overloaded in derived types (e.g. vehicles) to change handedness.
        public function get_IsRightHanded() : Bool {
        return true;
    }

    // ------------------------------------------------------------------------
        // constructor
        // Takes param1=up, param2=forward, param3=position, param4=side=can be null
        public function new(args:Array<Vec3>) {
        //trace("LocalSpace.constructor", args[0] is Vec3, args[1] is Vec3, args[2] is Vec3, args[3] is Vec3);
        if(args.length == 4)  {
            up = args[0];
            forward = args[1];
            position = args[2];
            side = args[3];
        }

        else if(args.length == 3)  {
            up = args[0];
            forward = args[1];
            position = args[2];
            SetUnitSideFromForwardAndUp();
        }

        else  {
            ResetLocalSpace();
        }
;
    }

    // ------------------------------------------------------------------------
        // reset transform: set local space to its identity state, equivalent to a
        // 4x4 homogeneous transform like this:
        //
        //     [ X 0 0 0 ]
        //     [ 0 1 0 0 ]
        //     [ 0 0 1 0 ]
        //     [ 0 0 0 1 ]
        //
        // where X is 1 for a left-handed system and -1 for a right-handed system.
        public function ResetLocalSpace() : Void {
        forward = Vec3.Backward;
        side = LocalRotateForwardToSide(Vec3.Forward);
        up = Vec3.Up;
        position = Vec3.Zero;
    }

    // ------------------------------------------------------------------------
        // transform a direction in global space to its equivalent in local space
        public function LocalizeDirection(globalDirection : Vec3) : Vec3 {
        // dot offset with local basis vectors to obtain local coordiantes
        return new Vec3(side.DotProduct(globalDirection), up.DotProduct(globalDirection), forward.DotProduct(globalDirection));
    }

    // ------------------------------------------------------------------------
        // transform a point in global space to its equivalent in local space
        public function LocalizePosition(globalPosition : Vec3) : Vec3 {
        // global offset from local origin
        var globalOffset : Vec3 = Vec3.VectorSubtraction(globalPosition, position);
        // dot offset with local basis vectors to obtain local coordiantes
        return LocalizeDirection(globalOffset);
    }

    // ------------------------------------------------------------------------
        // transform a point in local space to its equivalent in global space
        public function GlobalizePosition(localPosition : Vec3) : Vec3 {
        return Vec3.VectorAddition(position, GlobalizeDirection(localPosition));
    }

    // ------------------------------------------------------------------------
        // transform a direction in local space to its equivalent in global space
        public function GlobalizeDirection(localDirection : Vec3) : Vec3 {
        return Vec3.VectorAddition(Vec3.VectorAddition(Vec3.ScalarMultiplication(localDirection.x, side), Vec3.ScalarMultiplication(localDirection.y, up)), Vec3.ScalarMultiplication(localDirection.z, forward));
    }

    // ------------------------------------------------------------------------
        // set "side" basis vector to normalized cross product of forward and up
        public function SetUnitSideFromForwardAndUp() : Void {
        // derive new unit side basis vector from forward and up
        if(IsRightHanded)  {
            side = Vec3.CrossProduct(forward, up);
        }

        else  {
            side = Vec3.CrossProduct(up, forward);
        }

        side.Normalize();
    }

    // ------------------------------------------------------------------------
        // regenerate the orthonormal basis vectors given a new forward
        //(which is expected to have unit length)
        public function RegenerateOrthonormalBasisUF(newUnitForward : Vec3) : Void {
        forward = newUnitForward;
        // derive new side basis vector from NEW forward and OLD up
        SetUnitSideFromForwardAndUp();
        // derive new Up basis vector from new Side and new Forward
        //(should have unit length since Side and Forward are
        // perpendicular and unit length)
        if(IsRightHanded)  {
            up = Vec3.CrossProduct(side, forward);
        }

        else  {
            up = Vec3.CrossProduct(up, side);
        }
;
    }

    // for when the new forward is NOT know to have unit length
        public function RegenerateOrthonormalBasis(newForward : Vec3) : Void {
        newForward.Normalize();
        RegenerateOrthonormalBasisUF(newForward);
    }

    // for supplying both a new forward and and new up
        public function RegenerateOrthonormalBasis2(newForward : Vec3, newUp : Vec3) : Void {
        up = newUp;
        newForward.Normalize();
        RegenerateOrthonormalBasis(newForward);
    }

    // ------------------------------------------------------------------------
        // rotate, in the canonical direction, a vector pointing in the
        // "forward"(+Z) direction to the "side"(+/-X) direction
        public function LocalRotateForwardToSide(val : Vec3) : Vec3 {
        if(IsRightHanded)
    {  
      return new Vec3(-val.z, val.y, val.x);
    }
    return new Vec3(val.z, val.y, val.x);
    }

    // not currently used, just added for completeness
        public function GlobalRotateForwardToSide(val : Vec3) : Vec3 {
        var localForward : Vec3 = LocalizeDirection(val);
        var localSide : Vec3 = LocalRotateForwardToSide(localForward);
        return GlobalizeDirection(localSide);
    }

}

