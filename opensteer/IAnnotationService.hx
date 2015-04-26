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

// Provides methods to annotate the steering behaviors.
interface IAnnotationService {
    var IsEnabled(get, set) : Bool;

    function get_IsEnabled() : Bool;
    function set_IsEnabled(val : Bool) : Bool;
    function Redraw() : Void;
    /**

     * Adds a Trail

     * @param    trail The trail to add

     */    function AddTrail(trail : Trail) : Void;
    /**

     * Removes a specified trail

     * @param    trail The trail to remove

     */    function RemoveTrail(trail : Trail) : Void;
    /**

     * Draw all registered Trails

     */    function DrawAllTrails() : Void;
    /**

     * Draw the given registered Trail

     */    function DrawTrail(trail : Trail) : Void;
    /**

     * Clear all registered trails

     */    function ClearAllTrails() : Void;
    /**

     * Clear given trail

     * @param    trail The trail instance to clear

     */    function ClearTrail(trail : Trail) : Void;
    /**

     * @usage

     * Drawing of lines, circles and (filled) disks to annotate steering

     * behaviors.  When called during OpenSteerDemo's simulation update phase,

     * these functions call a "deferred draw" routine which buffer the

         * arguments for use during the redraw phase.

     *

     * note: "circle" means unfilled

     *       "disk" means filled

     *       "XZ" means on a plane parallel to the X and Z axes (perp to Y)

     *       "3d" means the circle is perpendicular to the given "axis"

     *       "segments" is the number of line segments used to draw the circle

     *

     */    /** Draws an opaque colored line segment between two locations in space.

      * 

     * @param    startPoint Start point of the line

     * @param    endPoint End point of the line

     * @param    color Color of the line

     */    function Line(startPoint : Vec3, endPoint : Vec3, color : Int) : Void;
    /**

     * Draws a circle on the XZ plane.

     * 

     * @param radius The radius of the circle.

     * @param center The center of the circle.

     * @param color The color of the circle.

     * @param segments The number of segments to use to draw the circle.

     */    function CircleXZ(radius : Float, center : Vec3, color : Int, segments : Int) : Void;
    /**

    * Draws a disk on the XZ plane.

    * 

    * @param radius The radius of the disk.

    * @param center The center of the disk.

    * @param color The color of the disk.

    * @param segments The number of segments to use to draw the disk

    */    function DiskXZ(radius : Float, center : Vec3, color : Int, segments : Int) : Void;
    /**

    * Draws a circle perpendicular to the given axis.

    * 

    * @param radius The radius of the circle.

    * @param center The center of the circle.

    * @param axis The axis of the circle.

    * @param color The color of the circle.

    * @param segments The number of segments to use to draw the circle.

    */    function Circle3D(radius : Float, center : Vec3, axis : Vec3, color : Int, segments : Int) : Void;
    /**

    * Draws a disk perpendicular to the given axis.

    * 

    * @param radius The radius of the disk.

    * @param center The center of the disk.

    * @param axis The axis of the disk.

    * @param color The color of the disk.

    * @param segments The number of segments to use to draw the disk.

    */    function Disk3D(radius : Float, center : Vec3, axis : Vec3, color : Int, segments : Int) : Void;
    /** 

    * Draws a circle (not filled) or disk (filled) on the XZ plane.

    * 

    * @param radius The radius of the circle/disk.

    * @param center The center of the circle/disk.

    * @param color The color of the circle/disk.

    * @param segments The number of segments to use to draw the circle/disk.

    * @param filled Flag indicating whether to draw a disk or circle.

    */    function CircleOrDiskXZ(radius : Float, center : Vec3, color : Int, segments : Int, filled : Bool) : Void;
    /**

    * Draws a circle (not filled) or disk (filled) perpendicular to the given axis.

    * 

    * @param radius The radius of the circle/disk.

    * @param center The center of the circle/disk.

    * @param axis The axis of the circle/disk.

    * @param color The color of the circle/disk.

    * @param segments The number of segments to use to draw the circle/disk.

    * @param filled Flag indicating whether to draw a disk or circle.

    */    function CircleOrDisk3D(radius : Float, center : Vec3, axis : Vec3, color : Int, segments : Int, filled : Bool) : Void;
    /**

    * Draws a circle (not filled) or disk (filled) perpendicular to the given axis.

    * 

    * @param radius The radius of the circle/disk.

    * @param axis The axis of the circle/disk.

    * @param center The center of the circle/disk.

    * @param color The color of the circle/disk.

    * @param segments The number of segments to use to draw the circle/disk.

    * @param filled Flag indicating whether to draw a disk or circle.

    * @param in3d Flag indicating whether to draw the disk/circle in 3D or the XZ plane.

    */    function CircleOrDisk(radius : Float, axis : Vec3, center : Vec3, color : Int, segments : Int, filled : Bool, in3d : Bool) : Void;
    /** 

    * Called when steerToAvoidObstacles decides steering is required.

    * 

    * @param minDistanceToCollision

    */    function AvoidObstacle(vehicle : IVehicle, minDistanceToCollision : Float) : Void;
    /** 

    * Called when steerToFollowPath decides steering is required.

    * 

    * @param future

    * @param onPath

    * @param target

    * @param outside

    */    function PathFollowing(future : Vec3, onPath : Vec3, target : Vec3, outside : Float) : Void;
    /**

     * Called when steerToAvoidCloseNeighbors decides steering is required.

     * 

     * @param other

     * @param additionalDistance

     */    function AvoidCloseNeighbor(other : IVehicle, additionalDistance : Float) : Void;
    /**

     * Called when steerToAvoidNeighbors decides steering is required.

     *

     * @param threat

     * @param steer

     * @param ourFuture

     * @param threatFuture

     */    function AvoidNeighbor(threat : IVehicle, steer : Float, ourFuture : Vec3, threatFuture : Vec3) : Void;
    /**

     * Draws lines from the vehicle's position showing its velocity and acceleration.

     *

     * @param vehicle The vehicle to annotate.

     */    function VelocityAcceleration(vehicle : IVehicle) : Void;
    /**

     * Draws lines from the vehicle's position showing its velocity and acceleration.

     * 

     * @param vehicle The vehicle to annotate.

     * @param maxLength The maximum length for the acceleration and velocity lines.

     */    function VelocityAcceleration2(vehicle : IVehicle, maxLength : Float) : Void;
    /**

     * Draws lines from the vehicle's position showing its velocity and acceleration.

     * 

     * @param vehicle The vehicle to annotate.

     * @param maxLengthAcceleration The maximum length for the acceleration line.

     * @param maxLengthVelocity The maximum length for the velocity line.

     */    function VelocityAcceleration3(vehicle : IVehicle, maxLengthAcceleration : Float, maxLengthVelocity : Float) : Void;
}

