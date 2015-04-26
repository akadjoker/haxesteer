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

class SimpleVehicle extends SteerLibrary {
    public var Curvature(get, null) : Float;
    public var SmoothedCurvature(get, null) : Float;
    public var SerialNumber(get, null) : Int;

    //public var VehicleMesh:TriangleMesh3D;            // For Papervision3D
        // give each vehicle a unique number
        var _SerialNumber : Int;
    static var serialNumberCounter : Int = 0;
    // Mass (defaults to unity so acceleration=force)
        var mass : Float;
    // size of bounding sphere, for obstacle avoidance, etc.
        var radius : Float;
    // speed along Forward direction. Because local space is
        // velocity-aligned, velocity = Forward * Speed
        var speed : Float;
    // the maximum steering force this vehicle can apply
        // (steering force is clipped to this magnitude)
        var maxForce : Float;
    // the maximum speed this vehicle is allowed to move
        // (velocity is clipped to this magnitude)
        var maxSpeed : Float;
    var curvature : Float;
    var lastForward : Vec3;
    var lastPosition : Vec3;
    var smoothedPosition : Vec3;
    var smoothedCurvature : Float;
    // The acceleration is smoothed
        var acceleration : Vec3;
    // constructor
        public function new(args:Array<Vec3>) {
    super(args);
        // set inital state
        Reset();
        // maintain unique serial numbers
        _SerialNumber = serialNumberCounter++;
    }

    // reset vehicle state
        override public function Reset() : Void {
        // reset LocalSpace state
        ResetLocalSpace();
        // reset SteerLibraryMixin state
        //FIXME: this is really fragile, needs to be redesigned
        super.Reset();
        Mass = 1.0;
        // Mass (defaults to 1 so acceleration=force)
        Speed = 0.0;
        // speed along Forward direction.
        Radius = 0.5;
        // size of bounding sphere
        MaxForce = 0.1;
        // steering force is clipped to this magnitude
        MaxSpeed = 1.0;
        // velocity is clipped to this magnitude
        // reset bookkeeping to do running averages of these quanities
        ResetSmoothedPosition(Vec3.Zero);
        ResetSmoothedCurvature();
        ResetAcceleration();
    }

    // get/set Mass
        override public function get_Mass() : Float {
        return mass;
    }

    override public function set_Mass(val : Float) : Float {
        mass = val;
        return val;
    }

    // get velocity of vehicle
        override public function get_Velocity() : Vec3 {
        return Vec3.ScalarMultiplication(speed, Forward);
    }

    // get/set speed of vehicle  (may be faster than taking mag of velocity)
        override public function get_Speed() : Float {
        return speed;
    }

    override public function set_Speed(val : Float) : Float {
        speed = val;
        return val;
    }

    // size of bounding sphere, for obstacle avoidance, etc.
        override public function get_Radius() : Float {
        return radius;
    }

    override public function set_Radius(val : Float) : Float {
        radius = val;
        return val;
    }

    // get/set maxForce
        override public function get_MaxForce() : Float {
        return maxForce;
    }

    override public function set_MaxForce(val : Float) : Float {
        maxForce = val;
        return val;
    }

    // get/set maxSpeed
        override public function get_MaxSpeed() : Float {
        return maxSpeed;
    }

    override public function set_MaxSpeed(val : Float) : Float {
        maxSpeed = val;
        return val;
    }

    // apply a given steering force to our momentum,
        // adjusting our orientation to maintain velocity-alignment.
        public function ApplySteeringForce(force : Vec3, elapsedTime : Float) : Void {
        var adjustedForce : Vec3 = AdjustRawSteeringForce(force, elapsedTime);
        // enforce limit on magnitude of steering force
        var clippedForce : Vec3 = VHelper.TruncateLength(adjustedForce, MaxForce);
        // compute acceleration and velocity
        var newAcceleration : Vec3 = Vec3.ScalarMultiplication(1 / Mass, clippedForce);
        var newVelocity : Vec3 = Velocity;
        // damp out abrupt changes and oscillations in steering acceleration
        // (rate is proportional to time step, then clipped into useful range)
        if(elapsedTime > 0)  {
            var smoothRate : Float = Utilities.Clip(9 * elapsedTime, 0.15, 0.4);
            acceleration = Utilities.BlendIntoAccumulator2(smoothRate, newAcceleration, acceleration);
        }

        // Euler integrate (per frame) acceleration into velocity
        newVelocity = Vec3.VectorAddition(newVelocity, Vec3.ScalarMultiplication(elapsedTime, acceleration));
        // enforce speed limit
        newVelocity = VHelper.TruncateLength(newVelocity, MaxSpeed);
        // update Speed
        Speed = newVelocity.Magnitude();
        // Euler integrate (per frame) velocity into position
        Position = Vec3.VectorAddition(Position, Vec3.ScalarMultiplication(elapsedTime, newVelocity));
        // regenerate local space (by default: align vehicle's forward axis with
        // new velocity, but this behavior may be overridden by derived classes.)
        RegenerateLocalSpace(newVelocity, elapsedTime);
        // maintain path curvature information
        MeasurePathCurvature(elapsedTime);
        // running average of recent positions
        smoothedPosition = Utilities.BlendIntoAccumulator2(elapsedTime * 0.06, Position, smoothedPosition);
    }

    // the default version: keep FORWARD parallel to velocity, change
        // UP as little as possible.
        public function RegenerateLocalSpace(newVelocity : Vec3, elapsedTime : Float) : Void {
        // adjust orthonormal basis vectors to be aligned with new velocity
        if(Speed > 0)  {
        RegenerateOrthonormalBasisUF(Vec3.ScalarMultiplication(1 / Speed, newVelocity));
        }

    }

    // alternate version: keep FORWARD parallel to velocity, adjust UP
        // according to a no-basis-in-reality "banking" behavior, something
        // like what birds and airplanes do.  (XXX experimental cwr 6-5-03)
        public function RegenerateLocalSpaceForBanking(newVelocity : Vec3, elapsedTime : Float) : Void {
        // the length of this global-upward-pointing vector controls the vehicle's
        // tendency to right itself as it is rolled over from turning acceleration
        var globalUp : Vec3 = new Vec3(0, 0.2, 0);
        // acceleration points toward the center of local path curvature, the
        // length determines how much the vehicle will roll while turning
        var accelUp : Vec3 = Vec3.ScalarMultiplication(0.05, acceleration);
        // combined banking, sum of UP due to turning and global UP
        var bankUp : Vec3 = Vec3.VectorAddition(accelUp, globalUp);
        // blend bankUp into vehicle's UP basis vector
        var smoothRate : Float = elapsedTime * 3.0;
        var tempUp : Vec3 = Up;
        tempUp = Utilities.BlendIntoAccumulator2(smoothRate, bankUp, tempUp);
        Up = tempUp;
        Up.Normalize();
        SteerLibrary.annotation.Line(Position, Vec3.VectorAddition(Position, Vec3.ScalarMultiplication(4, globalUp)), 0xFFFFFF);
        SteerLibrary.annotation.Line(Position, Vec3.VectorAddition(Position, Vec3.ScalarMultiplication(4, bankUp)), 0xFF9900);
        SteerLibrary.annotation.Line(Position, Vec3.VectorAddition(Position, Vec3.ScalarMultiplication(4, accelUp)), 0xCC0000);
        SteerLibrary.annotation.Line(Position, Vec3.VectorAddition(Position, Vec3.ScalarMultiplication(1, Up)), 0xFFFF00);
        // adjust orthonormal basis vectors to be aligned with new velocity
        if (Speed > 0) 
		{
            RegenerateOrthonormalBasisUF(Vec3.ScalarMultiplication(1 / Speed, newVelocity));
        }

    }

    // adjust the steering force passed to applySteeringForce.
        // allows a specific vehicle class to redefine this adjustment.
        // default is to disallow backward-facing steering at low speed.
        // xxx experimental 8-20-02
        public function AdjustRawSteeringForce(force : Vec3, deltaTime : Float) : Vec3 {
        var maxAdjustedSpeed : Float = 0.2 * MaxSpeed;
        if(Speed > maxAdjustedSpeed || Vec3.isEqual(force, Vec3.Zero))  {
            return force;
        }

        else  {
            var range : Float = (Speed / maxAdjustedSpeed);
            var cosine : Float = Utilities.Interpolate(Math.pow(range, 20), 1.0, -1.0);
            return VHelper.LimitMaxDeviationAngle(force, cosine, Forward);
        }

    }

    // apply a given braking force (for a given dt) to our momentum.
        // xxx experimental 9-6-02
        public function ApplyBrakingForce(rate : Float, deltaTime : Float) : Void {
        var rawBraking : Float = (Speed * rate);
        var clipBraking : Float = (((rawBraking < MaxForce)) ? rawBraking : MaxForce);
        Speed = (Speed - (clipBraking * deltaTime));
    }

    // predict position of this vehicle at some time in the future
        // (assumes velocity remains constant)
        override public function PredictFuturePosition(predictionTime : Float) : Vec3 {
        return Vec3.VectorAddition(Position, Vec3.ScalarMultiplication(predictionTime, Velocity));
    }

    // get instantaneous curvature (since last update)
        public function get_Curvature() : Float {
        return curvature;
    }

    // get/reset smoothedCurvature, smoothedAcceleration and smoothedPosition
        public function get_SmoothedCurvature() : Float {
        return smoothedCurvature;
    }

    public function ResetSmoothedCurvature(val : Float = 0) : Float {
        lastForward = Vec3.Zero;
        lastPosition = Vec3.Zero;
        return smoothedCurvature = curvature = val;
    }

    override public function get_Acceleration() : Vec3 {
        return acceleration;
    }

    public function get_SerialNumber() : Int {
        return _SerialNumber;
    }

    public function ResetAcceleration() : Vec3 {
        return ResetAcceleration2(Vec3.Zero);
    }

    public function ResetAcceleration2(val : Vec3) : Vec3 {
        return acceleration = val;
    }

    public function SmoothedPosition() : Vec3 {
        return smoothedPosition;
    }

    public function callResetSmoothedPosition() : Vec3 {
        return ResetSmoothedPosition(Vec3.Zero);
    }

    public function ResetSmoothedPosition(val : Vec3) : Vec3 {
        return smoothedPosition = val;
    }

    // set a random "2D" heading: set local Up to global Y, then effectively
        // rotate about it by a random angle (pick random forward, derive side).
        public function RandomizeHeadingOnXZPlane() : Void {
        Up = Vec3.Up;
        Forward = VHelper.RandomUnitVectorOnXZPlane();
        Side = LocalRotateForwardToSide(Forward);
    }

    // measure path curvature (1/turning-radius), maintain smoothed version
        function MeasurePathCurvature(elapsedTime : Float) : Void {
        if(elapsedTime > 0)  {
            var dP : Vec3 = Vec3.VectorSubtraction(lastPosition, Position);
            var dF : Vec3 = Vec3.ScalarMultiplication(1 / dP.Magnitude(), Vec3.VectorSubtraction(lastForward, Forward));
            var lateral : Vec3 = VHelper.PerpendicularComponent(dF, Forward);
            var sign : Float = ((lateral.DotProduct(Side) < 0)) ? 1.0 : -1.0;
            curvature = lateral.Magnitude() * sign;
            smoothedCurvature = Utilities.BlendIntoAccumulator(elapsedTime * 4.0, curvature, smoothedCurvature);
            lastForward = Forward;
            lastPosition = Position;
        }
    }

}

