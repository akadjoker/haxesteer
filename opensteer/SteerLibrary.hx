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

class SteerLibrary extends AbstractVehicle {

    static public var annotation : Annotation = new Annotation();
    // Wander behavior
        public var WanderSide : Float;
    public var WanderUp : Float;
    // Constructor: initializes state
        public function new(args:Array<Vec3>) 
		{
         super(args);
        // set inital state
        Reset();
    }

    // reset state
        public function Reset() : Void {
        // initial state of wander behavior
        WanderSide = 0.0;
        WanderUp = 0.0;
        // default to non-gaudyPursuitAnnotation
        GaudyPursuitAnnotation = false;
    }

    // -------------------------------------------------- steering behaviors
        public function SteerForWander(dt : Float) : Vec3 {
        // random walk WanderSide and WanderUp between -1 and +1
        var speed : Float = 12 * dt;
        // maybe this (12) should be an argument?
        WanderSide = Utilities.ScalarRandomWalk(WanderSide, speed, -1, 1);
        WanderUp = Utilities.ScalarRandomWalk(WanderUp, speed, -1, 1);
        // return a pure lateral steering vector: (+/-Side) + (+/-Up)
        return Vec3.VectorAddition(Vec3.ScalarMultiplication(WanderSide, this.Side), Vec3.ScalarMultiplication(WanderUp, this.Up));
    }

    // Seek behavior
        public function SteerForSeek(target : Vec3) : Vec3 {
        var desiredVelocity : Vec3 = Vec3.VectorSubtraction(target, this.Position);
        return Vec3.VectorSubtraction(desiredVelocity, this.Velocity);
    }

    // Flee behavior
        public function SteerForFlee(target : Vec3) : Vec3 {
        var desiredVelocity : Vec3 = Vec3.VectorSubtraction(this.Position, target);
        return Vec3.VectorSubtraction(desiredVelocity, this.Velocity);
    }

    // xxx proposed, experimental new seek/flee [cwr 9-16-02]
        public function xxxSteerForFlee(target : Vec3) : Vec3 {
        //  const Vec3 offset = position - target;
        var offset : Vec3 = Vec3.VectorSubtraction(this.Position, target);
        var desiredVelocity : Vec3 = VHelper.TruncateLength(offset, (this.MaxSpeed));
        //xxxnew
        return Vec3.VectorSubtraction(desiredVelocity, this.Velocity);
    }

    public function xxxSteerForSeek(target : Vec3) : Vec3 {
        //  const Vec3 offset = target - position;
        var offset : Vec3 = Vec3.VectorSubtraction(target, this.Position);
        var desiredVelocity : Vec3 = VHelper.TruncateLength(offset, this.MaxSpeed);
        //xxxnew
        return Vec3.VectorSubtraction(desiredVelocity, this.Velocity);
    }

    // Path Following behaviors
        public function SteerToFollowPath(direction : Int, predictionTime : Float, path : Pathway) : Vec3 {
        // our goal will be offset from our path distance by this amount
        var pathDistanceOffset : Float = (direction * predictionTime * this.Speed);
        // predict our future position
        var futurePosition : Vec3 = this.PredictFuturePosition(predictionTime);
        // measure distance along path of our current and predicted positions
        var nowPathDistance : Float = (path.MapPointToPathDistance(this.Position));
        var futurePathDistance : Float = (path.MapPointToPathDistance(futurePosition));
        // are we facing in the correction direction?
        var rightway : Bool = (((pathDistanceOffset > 0)) ? (nowPathDistance < futurePathDistance) : (nowPathDistance > futurePathDistance));
        // find the point on the path nearest the predicted future position
        // XXX need to improve calling sequence, maybe change to return a
        // XXX special path-defined object which includes two Vector3s and a
        // XXX bool (onPath,tangent (ignored), withinPath)
        var tangent : Vec3=new Vec3();
        var outside : Float=0;
        var temp : Array<Dynamic> = path.MapPointToPath(futurePosition, tangent, outside);
        var onPath : Vec3 = temp[0];
        tangent = temp[1];
        outside = temp[2];
        // no steering is required if (a) our future position is inside
        // the path tube and (b) we are facing in the correct direction
        if((outside < 0) && rightway)  {
            // all is well, return zero steering
            return Vec3.Zero;
        }

        else  {
            // otherwise we need to steer towards a target point obtained
            // by adding pathDistanceOffset to our current path position
            var targetPathDistance : Float = (nowPathDistance + pathDistanceOffset) + 0.0;
            var target : Vec3 = path.MapPathDistanceToPoint(targetPathDistance);
            annotation.PathFollowing(futurePosition, onPath, target, outside);
            // return steering to seek target on path
            return SteerForSeek(target);
        }
;
    }

    public function SteerToStayOnPath(predictionTime : Float, path : Pathway) : Vec3 {
        // predict our future position
        var futurePosition : Vec3 = this.PredictFuturePosition(predictionTime);
        // find the point on the path nearest the predicted future position
        var tangent : Vec3=new Vec3();
        var outside : Float=0;
        var temp : Array<Dynamic> = path.MapPointToPath(futurePosition, tangent, outside);
        var onPath : Vec3 = temp[0];
        tangent = temp[1];
        outside = temp[2];
        if(outside < 0)  {
            // our predicted future position was in the path,
            // return zero steering.
            return Vec3.Zero;
        }

        else  {
            // our predicted future position was outside the path, need to
            // steer towards it.  Use onPath projection of futurePosition
            // as seek target
            annotation.PathFollowing(futurePosition, onPath, onPath, outside);
            return SteerForSeek(onPath);
        }

    }

    // ------------------------------------------------------------------------
        // Obstacle Avoidance behavior
        //
        // Returns a steering force to avoid a given obstacle.  The purely
        // lateral steering force will turn our this towards a silhouette edge
        // of the obstacle.  Avoidance is required when (1) the obstacle
        // intersects the this's current path, (2) it is in front of the
        // this, and (3) is within minTimeToCollision seconds of travel at the
        // this's current velocity.  Returns a zero vector value (Vec3::zero)
        // when no avoidance is required.
        public function SteerToAvoidObstacle(minTimeToCollision : Float, obstacle : IObstacle) : Vec3 {
        var avoidance : Vec3 = obstacle.SteerToAvoid(this, minTimeToCollision);
        // XXX more annotation modularity problems (assumes spherical obstacle)
        if(Vec3.isNotEqual(avoidance, Vec3.Zero))  {
            annotation.AvoidObstacle(this, minTimeToCollision * this.Speed);
        }
;
        return avoidance;
    }

    // avoids all obstacles in an ObstacleGroup
        public function SteerToAvoidObstacles(minTimeToCollision : Float, obstacles : Array<IObstacle>) : Vec3 {
        var avoidance : Vec3 = Vec3.Zero;
        var nearest : PathIntersection = new PathIntersection();
        var next : PathIntersection = new PathIntersection();
        var minDistanceToCollision : Float = minTimeToCollision * this.Speed;
        next.intersect = false;
        nearest.intersect = false;
        // test all obstacles for intersection with my forward axis,
        // select the one whose point of intersection is nearest
        for(o in obstacles/* AS3HX WARNING could not determine type for var: o exp: EIdent(obstacles) type: Array<IObstacle>*/) {
            //FIXME: this should be a generic call on Obstacle, rather than this code which presumes the obstacle is spherical
            next = FindNextIntersectionWithSphere(cast(o, SphericalObstacle), next);
            if(nearest.intersect == false || (next.intersect != false && next.distance < nearest.distance)) 
                nearest = next;
        }
;
        // when a nearest intersection was found
        if((nearest.intersect != false) && (nearest.distance < minDistanceToCollision))  {
            // show the corridor that was checked for collisions
            annotation.AvoidObstacle(this, minDistanceToCollision);
            // compute avoidance steering force: take offset from obstacle to me,
            // take the component of that which is lateral (perpendicular to my
            // forward direction), set length to maxForce, add a bit of forward
            // component (in capture the flag, we never want to slow down)
            var offset : Vec3 = Vec3.VectorSubtraction(this.Position, nearest.obstacle.Center);
            avoidance = VHelper.PerpendicularComponent(offset, (this.Forward));
            avoidance.Normalize();
            avoidance = Vec3.ScalarMultiplication(this.MaxForce, avoidance);
            avoidance = Vec3.VectorAddition(avoidance, (Vec3.ScalarMultiplication(this.MaxForce * 0.75, this.Forward)));
        }
;
        return avoidance;
    }

    // ------------------------------------------------------------------------
        // Unaligned collision avoidance behavior: avoid colliding with other
        // nearby vehicles moving in unconstrained directions.  Determine which
        // (if any) other other this we would collide with first, then steers
        // to avoid the site of that potential collision.  Returns a steering
        // force vector, which is zero length if there is no impending collision.
        public function SteerToAvoidNeighbors(minTimeToCollision : Float, others : Array<IVehicle>) : Vec3 {
        // first priority is to prevent immediate interpenetration
        var separation : Vec3 = SteerToAvoidCloseNeighbors(0, others);
        if(Vec3.isNotEqual(separation, Vec3.Zero)) 
            return separation;
        // otherwise, go on to consider potential future collisions
        var steer : Float = 0;
        var threat : IVehicle = null;
        // Time (in seconds) until the most immediate collision threat found
        // so far.  Initial value is a threshold: don't look more than this
        // many frames into the future.
        var minTime : Float = minTimeToCollision;
        // xxx solely for annotation
        var xxxThreatPositionAtNearestApproach : Vec3 = Vec3.Zero;
        var xxxOurPositionAtNearestApproach : Vec3 = Vec3.Zero;
        // for each of the other vehicles, determine which (if any)
        // pose the most immediate threat of collision.
        for(other in others/* AS3HX WARNING could not determine type for var: other exp: EIdent(others) type: Array<IVehicle>*/) {
            if(other != this)  {
                // avoid when future positions are this close (or less)
                var collisionDangerThreshold : Float = this.Radius * 2;
                // predicted time until nearest approach of "this" and "other"
                var time : Float = PredictNearestApproachTime(other);
                // If the time is in the future, sooner than any other
                // threatened collision...
                if((time >= 0) && (time < minTime))  {
                    // if the two will be close enough to collide,
                    // make a note of it
                    if(ComputeNearestApproachPositions(other, time) < collisionDangerThreshold)  {
                        minTime = time;
                        threat = other;
                        xxxThreatPositionAtNearestApproach = hisPositionAtNearestApproach;
                        xxxOurPositionAtNearestApproach = ourPositionAtNearestApproach;
                    }
;
                }
;
            }
        }
;
        // if a potential collision was found, compute steering to avoid
        if(threat != null)  {
            // parallel: 1, perpendicular: 0, anti-parallel: -1
            var parallelness : Float = this.Forward.DotProduct(threat.Forward);
            var angle : Float = 0.707;
            if(parallelness < -angle)  {
                // anti-parallel "head on" paths:
                // steer away from future threat position
                var offset : Vec3 = Vec3.VectorSubtraction(xxxThreatPositionAtNearestApproach, this.Position);
                var sideDot : Float = offset.DotProduct(this.Side);
                steer = ((sideDot > 0)) ? -1.0 : 1.0;
            }

            else  {
                if(parallelness > angle)  {
                    // parallel paths: steer away from threat
                    var offset : Vec3 = Vec3.VectorSubtraction(threat.Position, this.Position);
                    var sideDot  : Float= offset.DotProduct(this.Side);
                    steer = ((sideDot > 0)) ? -1.0 : 1.0;
                }

                else  {
                    // perpendicular paths: steer behind threat
                    // (only the slower of the two does this)
                    if(threat.Speed <= this.Speed)  {
                        var sideDot:Float = this.Side.DotProduct(threat.Velocity);
                        steer = ((sideDot > 0)) ? -1.0 : 1.0;
                    }
;
                }

            }

            annotation.AvoidNeighbor(threat, steer, xxxOurPositionAtNearestApproach, xxxThreatPositionAtNearestApproach);
        }
;
        return Vec3.ScalarMultiplication(steer, this.Side);
    }

    // Given two vehicles, based on their current positions and velocities,
        // determine the time until nearest approach
        public function PredictNearestApproachTime(other : IVehicle) : Float {
        // imagine we are at the origin with no velocity,
        // compute the relative velocity of the other this
        var myVelocity : Vec3 = this.Velocity;
        var otherVelocity : Vec3 = other.Velocity;
        var relVelocity : Vec3 = Vec3.VectorSubtraction(otherVelocity, myVelocity);
        var relSpeed : Float = relVelocity.Magnitude();
        // for parallel paths, the vehicles will always be at the same distance,
        // so return 0 (aka "now") since "there is no time like the present"
        if(relSpeed == 0) 
            return 0;
        // Now consider the path of the other this in this relative
        // space, a line defined by the relative position and velocity.
        // The distance from the origin (our this) to that line is
        // the nearest approach.
        // Take the unit tangent along the other this's path
        var relTangent : Vec3 = Vec3.ScalarMultiplication(1 / relSpeed, relVelocity);
        // find distance from its path to origin (compute offset from
        // other to us, find length of projection onto path)
        var relPosition : Vec3 = Vec3.VectorSubtraction(this.Position, other.Position);
        var projection : Float = relTangent.DotProduct(relPosition);
        return projection / relSpeed;
    }

    // Given the time until nearest approach (predictNearestApproachTime)
        // determine position of each this at that time, and the distance
        // between them
        public function ComputeNearestApproachPositions(other : IVehicle, time : Float) : Float {
        var myTravel : Vec3 = Vec3.ScalarMultiplication(this.Speed * time, this.Forward);
        var otherTravel : Vec3 = Vec3.ScalarMultiplication(other.Speed * time, other.Forward);
        var myFinal : Vec3 = Vec3.VectorAddition(this.Position, myTravel);
        var otherFinal : Vec3 = Vec3.VectorAddition(other.Position, otherTravel);
        // xxx for annotation
        ourPositionAtNearestApproach = myFinal;
        hisPositionAtNearestApproach = otherFinal;
        return Vec3.Distance(myFinal, otherFinal);
    }

    /// XXX globals only for the sake of graphical annotation
        var hisPositionAtNearestApproach : Vec3;
    var ourPositionAtNearestApproach : Vec3;
    // ------------------------------------------------------------------------
        // avoidance of "close neighbors" -- used only by steerToAvoidNeighbors
        //
        // XXX  Does a hard steer away from any other agent who comes withing a
        // XXX  critical distance.  Ideally this should be replaced with a call
        // XXX  to steerForSeparation.
        public function SteerToAvoidCloseNeighbors(minSeparationDistance : Float, others : Array<IVehicle>) : Vec3 {
        // for each of the other vehicles...
        for(other in others/* AS3HX WARNING could not determine type for var: other exp: EIdent(others) type: Array<IVehicle>*/) {
            if(other != this) 
                /*this*///)
             {
                var sumOfRadii : Float = this.Radius + other.Radius;
                var minCenterToCenter : Float = minSeparationDistance + sumOfRadii;
                var offset : Vec3 = Vec3.VectorSubtraction(other.Position, this.Position);
                var currentDistance : Float = offset.Magnitude();
                if(currentDistance < minCenterToCenter)  {
                    annotation.AvoidCloseNeighbor(other, minSeparationDistance);
                    VHelper.PerpendicularComponent(offset, (this.Forward));
                    offset = Vec3.Negate(offset);
                    return offset;
                }
            }
;
        }
;
        // otherwise return zero
        return Vec3.Zero;
    }

    // ------------------------------------------------------------------------
        // used by boid behaviors
        public function IsInBoidNeighborhood(other : IVehicle, minDistance : Float, maxDistance : Float, cosMaxAngle : Float) : Bool {
        if(other == this)  {
            return false;
        }

        else  {
            var offset : Vec3 = Vec3.VectorSubtraction(other.Position, this.Position);
            var distanceSquared : Float = offset.SquaredMagnitude();
            // definitely in neighborhood if inside minDistance sphere
            if(distanceSquared < (minDistance * minDistance))  {
                return true;
            }

            else  {
                // definitely not in neighborhood if outside maxDistance sphere
                if(distanceSquared > (maxDistance * maxDistance))  {
                    return false;
                }

                else  {
                    // otherwise, test angular offset from forward axis
                    var unitOffset : Vec3 = Vec3.ScalarMultiplication(1 / Math.sqrt(distanceSquared), offset);
                    var forwardness : Float = this.Forward.DotProduct(unitOffset);
                    return forwardness > cosMaxAngle;
                }
;
            }
;
        }

    }

    // ------------------------------------------------------------------------
        // Separation behavior -- determines the direction away from nearby boids
        public function SteerForSeparation(maxDistance : Float, cosMaxAngle : Float, flock : Array<IVehicle>) : Vec3 {
        // steering accumulator and count of neighbors, both initially zero
        var steering : Vec3 = Vec3.Zero;
        var neighbors : Int = 0;
        // for each of the other vehicles...
        var i : Int = 0;
        while(i < flock.length) {
            var other : IVehicle = flock[i];
            if(IsInBoidNeighborhood(other, this.Radius * 3, maxDistance, cosMaxAngle))  {
                // add in steering contribution
                // (opposite of the offset direction, divided once by distance
                // to normalize, divided another time to get 1/d falloff)
                var offset : Vec3 = Vec3.VectorSubtraction(other.Position, this.Position);
                var distanceSquared : Float = offset.DotProduct(offset);
                steering = Vec3.VectorAddition(steering, (Vec3.ScalarMultiplication(1 / -distanceSquared, offset)));
                // count neighbors
                neighbors++;
            }
            i++;
        }
;
        // divide by neighbors, then normalize to pure direction
        if(neighbors > 0)  {
            steering = Vec3.ScalarMultiplication(1 / neighbors, steering);
            steering.Normalize();
        }
;
        return steering;
    }

    // ------------------------------------------------------------------------
        // Alignment behavior
        public function SteerForAlignment(maxDistance : Float, cosMaxAngle : Float, flock : Array<IVehicle>) : Vec3 {
        // steering accumulator and count of neighbors, both initially zero
        var steering : Vec3 = Vec3.Zero;
        var neighbors : Int = 0;
        // for each of the other vehicles...
        var i : Int = 0;
        while(i < flock.length) {
            var other : IVehicle = flock[i];
            if(IsInBoidNeighborhood(other, this.Radius * 3, maxDistance, cosMaxAngle))  {
                // accumulate sum of neighbor's heading
                steering = Vec3.VectorAddition(steering, other.Forward);
                // count neighbors
                neighbors++;
            }
            i++;
        }
;
        // divide by neighbors, subtract off current heading to get error-
        // correcting direction, then normalize to pure direction
        if(neighbors > 0)  {
            steering = Vec3.VectorSubtraction(Vec3.ScalarMultiplication(1 / neighbors, steering), this.Forward);
            steering.Normalize();
        }
;
        return steering;
    }

    // ------------------------------------------------------------------------
        // Cohesion behavior
        public function SteerForCohesion(maxDistance : Float, cosMaxAngle : Float, flock : Array<IVehicle>) : Vec3 {
        // steering accumulator and count of neighbors, both initially zero
        var steering : Vec3 = Vec3.Zero;
        var neighbors : Int = 0;
        // for each of the other vehicles...
        var i : Int = 0;
        while(i < flock.length) {
            var other : IVehicle = flock[i];
            if(IsInBoidNeighborhood(other, this.Radius * 3, maxDistance, cosMaxAngle))  {
                // accumulate sum of neighbor's positions
                steering = Vec3.VectorAddition(steering, other.Position);
                // count neighbors
                neighbors++;
            }
            i++;
        }
;
        // divide by neighbors, subtract off current position to get error-
        // correcting direction, then normalize to pure direction
        if(neighbors > 0)  {
            steering = Vec3.VectorSubtraction(Vec3.ScalarMultiplication(1 / neighbors, steering), this.Position);
            steering.Normalize();
        }
;
        return steering;
    }

    // ------------------------------------------------------------------------
        // pursuit of another this (& version with ceiling on prediction time)
        public function SteerForPursuit(quarry : IVehicle) : Vec3 {
        return SteerForPursuit2(quarry, Math.POSITIVE_INFINITY);
    }

    public function SteerForPursuit2(quarry : IVehicle, maxPredictionTime : Float) : Vec3 {
        // offset from this to quarry, that distance, unit vector toward quarry
        var offset : Vec3 = Vec3.VectorSubtraction(quarry.Position, this.Position);
        var distance : Float = offset.Magnitude();
        var unitOffset : Vec3 = Vec3.ScalarMultiplication(1 / distance, offset);
        // how parallel are the paths of "this" and the quarry
        // (1 means parallel, 0 is pependicular, -1 is anti-parallel)
        var parallelness : Float = this.Forward.DotProduct(quarry.Forward);
        // how "forward" is the direction to the quarry
        // (1 means dead ahead, 0 is directly to the side, -1 is straight back)
        var forwardness : Float = this.Forward.DotProduct(unitOffset);
        var directTravelTime : Float = distance / this.Speed;
        var f : Int = Utilities.IntervalComparison(forwardness, -0.707, 0.707);
        var p : Int = Utilities.IntervalComparison(parallelness, -0.707, 0.707);
        var timeFactor : Float = 0;
        // to be filled in below
        var color : Int = 0x000000;
        
        // estimated time until intercept of quarry
        var et : Float = directTravelTime * timeFactor;
        // xxx experiment, if kept, this limit should be an argument
        var etl : Float = ((et > maxPredictionTime)) ? maxPredictionTime : et;
        // estimated position of quarry at intercept
        var target : Vec3 = quarry.PredictFuturePosition(etl);
        // annotation
        annotation.Line(this.Position, target, (GaudyPursuitAnnotation) ? color : 0x666666);
        return SteerForSeek(target);
    }

    // for annotation
        public var GaudyPursuitAnnotation : Bool;
    // ------------------------------------------------------------------------
        // evasion of another this
        public function SteerForEvasion(menace : IVehicle, maxPredictionTime : Float) : Vec3 {
        // offset from this to menace, that distance, unit vector toward menace
        var offset : Vec3 = Vec3.VectorSubtraction(menace.Position, this.Position);
        var distance : Float = offset.Magnitude();
        var roughTime : Float = distance / menace.Speed;
        var predictionTime : Float = (((roughTime > maxPredictionTime)) ? maxPredictionTime : roughTime);
        var target : Vec3 = menace.PredictFuturePosition(predictionTime);
        return SteerForFlee(target);
    }

    // ------------------------------------------------------------------------
        // tries to maintain a given speed, returns a maxForce-clipped steering
        // force along the forward/backward axis
        public function SteerForTargetSpeed(targetSpeed : Float) : Vec3 {
        var mf : Float = this.MaxForce;
        var speedError : Float = targetSpeed - this.Speed;
        return Vec3.ScalarMultiplication(Utilities.Clip(speedError, -mf, mf), this.Forward);
    }

    // ----------------------------------------------------------- utilities
        // XXX these belong somewhere besides the steering library
        // XXX above AbstractVehicle, below SimpleVehicle
        // XXX ("utility this"?)
        // xxx cwr experimental 9-9-02 -- names OK?
        public function IsAhead(target : Vec3, cosThreshold : Float = 0.707) : Bool {
        var targetDirection : Vec3 = Vec3.VectorSubtraction(target, this.Position);
        targetDirection.Normalize();
        return this.Forward.DotProduct(targetDirection) > cosThreshold;
    }

    public function IsAside(target : Vec3, cosThreshold : Float = 0.707) : Bool {
        var targetDirection : Vec3 = Vec3.VectorSubtraction(target, this.Position);
        targetDirection.Normalize();
        var dp : Float = this.Forward.DotProduct(targetDirection);
        return (dp < cosThreshold) && (dp > -cosThreshold);
    }

    public function IsBehind(target : Vec3, cosThreshold : Float = -0.707) : Bool {
        var targetDirection : Vec3 = Vec3.VectorSubtraction(target, this.Position);
        targetDirection.Normalize();
        return this.Forward.DotProduct(targetDirection) < cosThreshold;
    }

    // xxx experiment cwr 9-6-02
        function FindNextIntersectionWithSphere(obs : SphericalObstacle, intersection : PathIntersection) : PathIntersection {
        // This routine is based on the Paul Bourke's derivation in:
        //   Intersection of a Line and a Sphere (or circle)
        //   http://www.swin.edu.au/astronomy/pbourke/geometry/sphereline/
        var b : Float;
        var c : Float;
        var d : Float;
        var p : Float;
        var q : Float;
        var s : Float;
        var lc : Vec3;
        // initialize pathIntersection object
        intersection.intersect = false;
        intersection.obstacle = obs;
        // find "local center" (lc) of sphere in boid's coordinate space
        lc = this.LocalizePosition(obs.Center);
        // computer line-sphere intersection parameters
        b = -2 * lc.z;
        c = ((lc.x * lc.x) + (lc.y * lc.y) + (lc.z * lc.z)) - ((obs.Radius + this.Radius) * (obs.Radius + this.Radius));
        d = (b * b) - (4 * c);
        // when the path does not intersect the sphere
        if(d < 0)  {
            return intersection;
        }
;
        // otherwise, the path intersects the sphere in two points with
        // parametric coordinates of "p" and "q".
        // (If "d" is zero the two points are coincident, the path is tangent)
        s = Math.sqrt(d);
        p = (-b + s) / 2;
        q = (-b - s) / 2;
        // both intersections are behind us, so no potential collisions
        if((p < 0) && (q < 0))  {
            return intersection;
        }
;
        // at least one intersection is in front of us
        intersection.intersect = true;
        intersection.distance = (((p > 0) && (q > 0))) ? // both intersections are in front of us, find nearest one
        (((p < q)) ? p : q) : // otherwise only one intersections is in front, select it
        (((p > 0)) ? p : q);
        return intersection;
    }

}

