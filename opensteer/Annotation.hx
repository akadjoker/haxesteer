// ----------------------------------------------------------------------------
// PaperSteer - Papervision3D Port of OpenSteer
// Port by Mohammad Haseeb aka M.H.A.Q.S.
// http://www.tabinda.net
// AS3 Refactor by Andras Csizmadia <andras@vpmedia.eu> (No PV3D dependency)
// HaXe Port by Andras Csizmadia <andras@vpmedia.eu> 
// HaXe3 Port by Luis Santos AKA DJOKER <djokertheripper@gmail.com>  https://djokergames.wordpress.com/ (remove gdx  dependency)
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
import com.gdx.gl.batch.BatchPrimitives;
import com.gdx.scene3d.buffer.Imidiatemode;
import com.gdx.scene3d.Camera;
import com.gdx.scene3d.Scene;

/**

     *  This class adds OpenSteerDemo-based graphical annotation functionality to a

     *  given base class, which is typically something that supports the AbstractVehicle interface.

     *  @author Mohammad Haseeb

     */
   class Annotation implements IAnnotationService 
   {
    public var IsEnabled(get, set) : Bool;

    var trails : Array<Trail>;
    var isenabled : Bool;

	public var scene:Scene;
    //PV3D Render Variables
        //public var LineList:Lines3D;
        //public var LineTexture:LineMaterial;
        /**

         * constructor

         */   

	 public function new()
	 {
        isenabled = false;
        trails = new Array<Trail>();
		//render = new BatchPrimitives(500);
		//render = new Imidiatemode(500);
    }

    /**

         * Indicates whether annotation is enabled.

         * @return Boolean

         */   
      public function get_IsEnabled() : Bool {
        return isenabled;
    }

    public function set_IsEnabled(val : Bool) : Bool {
        isenabled = val;
        return val;
    }

    public function Redraw() : Void 
	{
	
    }

    /**

         * @inheritDoc

         *

         */    
     public function AddTrail(trail : Trail) : Void 
	 {
        trails.push(trail);
    }

    /** Removes the specified Trail.

         * @inheritDoc

        * @param trail The trail to remove

        */    
  public function RemoveTrail(trail : Trail) : Void 
	{
        trails.splice(Lambda.indexOf(trails,trail), 1);
    }

    /** Draws all registered Trails.

         * @inheritDoc

         */    public function DrawAllTrails() : Void
		 {
    }

    /**

         * Draw the given registered Trail

         */    public function DrawTrail(trail : Trail) : Void
		 {
    }

    /** Clears all registered Trails.

         *

         */    public function ClearAllTrails() : Void {
    }

    /** Clear a registered Trail.

         *

         */    public function ClearTrail(trail : Trail) : Void {
        trail.Clear();
    }

    /** ------------------------------------------------------------------------

        * drawing of lines, circles and (filled) disks to annotate steering

        * behaviors.  When called during OpenSteerDemo's simulation update phase,

        * these functions call a "deferred draw" routine which buffer the

        * arguments for use during the redraw phase.

        *

        * note: "circle" means unfilled

        *       "disk" means filled

        *       "XZ" means on a plane parallel to the X and Z axes (perp to Y)

        *       "3d" means the circle is perpendicular to the given "axis"

        *       "segments" is the number of line segments used to draw the circle

        */    /**  Draw an opaque colored line segment between two locations in space

         * @param startPoint A 3D point in space to start the line

         * <p/>

         * @param endPoint A 3D point in space where the line ends

         * <p/>

         * @param color An unsigned integer for the color of the object

         */    public function Line(startPoint : Vec3, endPoint : Vec3, color : Int) : Void 
		 {
			 if (scene != null)
			 {
				 scene.lines.line3D(startPoint.x, startPoint.y, startPoint.z, endPoint.x, endPoint.y, endPoint.z, 1, 0, 0, 1);
			 
			 }
       //  render.line3D(startPoint.x, startPoint.y, startPoint.z, endPoint.x, endPoint.y, endPoint.z, 1, 0, 0, 1);
		//	 trace(startPoint + " -- " + endPoint);
		 }

    /**  Draw a circle on the XZ plane

         * @param radius The size of the Circle

         * <p/>

         * @param center A 3D point in space where the line ends

         * <p/>

         * @param color An unsigned integer for the color of the object

         * <p/>

         * @param segments An integer or the number of line segments used to draw the circle

         */    public function CircleXZ(radius : Float, center : Vec3, color : Int, segments : Int) : Void {
        CircleOrDiskXZ(radius, center, color, segments, false);
    }

    /**  Draw a disk on the XZ plane

         * @param radius The size of the disk

         * <p/>

         * @param center A 3D point in space where the line ends

         * <p/>

         * @param color An unsigned integer for the color of the object

         * <p/>

         * @param segments An integer or the number of line segments used to draw the disk

         */    public function DiskXZ(radius : Float, center : Vec3, color : Int, segments : Int) : Void {
        CircleOrDiskXZ(radius, center, color, segments, true);
    }

    /**  Draw a circle perpendicular to the given axis

         * @param radius The size of the circle

         * <p/>

         * @param center A 3D point in space where the line ends

         * <p/>

         * @param axis A 3D point in space to tell the axis of the Circle

         * <p/>

         * @param color An unsigned integer for the color of the object

         * <p/>

         * @param segments An integer or the number of line segments used to draw the circle

         */    public function Circle3D(radius : Float, center : Vec3, axis : Vec3, color : Int, segments : Int) : Void {
        CircleOrDisk3D(radius, center, axis, color, segments, false);
    }

    /**  Draw a disk perpendicular to the given axis

         * @param radius The size of the disk

         * <p/>

         * @param center A 3D point in space where the line ends

         * <p/>

         * @param axis A 3D point in space to tell the axis of the Circle

         * <p/>

         * @param color An unsigned integer for the color of the object

         * <p/>

         * @param segments An integer or the number of line segments used to draw the disk

         */    public function Disk3D(radius : Float, center : Vec3, axis : Vec3, color : Int, segments : Int) : Void {
        CircleOrDisk3D(radius, center, axis, color, segments, true);
    }

    /** Support for annotation circles

        */    public function CircleOrDiskXZ(radius : Float, center : Vec3, color : Int, segments : Int, filled : Bool) : Void {
        CircleOrDisk(radius, Vec3.Zero, center, color, segments, filled, false);
    }

    /** Support for annotation circles

        */    public function CircleOrDisk3D(radius : Float, center : Vec3, axis : Vec3, color : Int, segments : Int, filled : Bool) : Void {
        CircleOrDisk(radius, axis, center, color, segments, filled, true);
    }

    /** Support for annotation circles

        */    public function CircleOrDisk(radius : Float, axis : Vec3, center : Vec3, color : Int, segments : Int, filled : Bool, in3d : Bool) : Void {
    }

    /** Called when steerToAvoidObstacles decides steering is required

        * (default action is to do nothing, layered classes can overload it)

        */    public function AvoidObstacle(vehicle : IVehicle, minDistanceToCollision : Float) : Void {
        var boxSide : Vec3 = Vec3.ScalarMultiplication(vehicle.Radius, vehicle.Side);
        var boxFront : Vec3 = Vec3.ScalarMultiplication(minDistanceToCollision, vehicle.Forward);
        var FR : Vec3 = Vec3.VectorAddition(vehicle.Position, Vec3.VectorSubtraction(boxFront, boxSide));
        var FL : Vec3 = Vec3.VectorAddition(vehicle.Position, Vec3.VectorAddition(boxFront, boxSide));
        var BR : Vec3 = Vec3.VectorSubtraction(vehicle.Position, boxSide);
        var BL : Vec3 = Vec3.VectorAddition(vehicle.Position, boxSide);
        Line(FR, FL, 255);
        Line(FL, BL, 255);
        Line(BL, BR, 255);
        Line(BR, FR, 255);
    }

    /** called when steerToFollowPath decides steering is required

        * (default action is to do nothing, layered classes can overload it)

        */    public function PathFollowing(future : Vec3, onPath : Vec3, target : Vec3, outside : Float) : Void {
    }

    /** called when steerToAvoidCloseNeighbors decides steering is required

        * (default action is to do nothing, layered classes can overload it)

        */    public function AvoidCloseNeighbor(other : IVehicle, additionalDistance : Float) : Void 
		{
    }

    /** called when steerToAvoidNeighbors decides steering is required

        * (default action is to do nothing, layered classes can overload it)

        */    public function AvoidNeighbor(threat : IVehicle, steer : Float, ourFuture : Vec3, threatFuture : Vec3) : Void 
		{
			//trace("anotae visinhos");
        }

    /** Caller Function

         */    public function VelocityAcceleration(vehicle : IVehicle) : Void {
        VelocityAcceleration3(vehicle, 3, 3);
    }

    /** Caller Function

         */    public function VelocityAcceleration2(vehicle : IVehicle, maxLength : Float) : Void {
        VelocityAcceleration3(vehicle, maxLength, maxLength);
    }

    /**

         * @param vehicle An IVehicle Object

         * <p/>

         * @param maxLengthAcceleration A number to tell the maximum scale of acceleration

         * <p/>

         * @param maxLengthVelocity A Number to tell the maximum scale of Velocity

         */   
       public function VelocityAcceleration3(vehicle : IVehicle, maxLengthAcceleration : Float, maxLengthVelocity : Float) : Void
	   {
        var desat : Int = 102;
        var vColor : Int = 0xffffff;
        // pinkish
        var aColor : Int = 0xaaaaff;
        // bluish
		var depth:Float=5.0;
        var aScale : Float = maxLengthAcceleration / vehicle.MaxForce*depth;
        var vScale : Float = maxLengthVelocity / vehicle.MaxSpeed*depth;
        var p : Vec3 = vehicle.Position;
        Line(p, Vec3.VectorAddition(p, Vec3.ScalarMultiplication(vScale, vehicle.Velocity)), vColor);
        Line(p, Vec3.VectorAddition(p, Vec3.ScalarMultiplication(aScale, vehicle.Acceleration)), aColor);
    }
 public function Ray(a:Vec3,b:Vec3) : Void
	   {
        
        Line(a,b, 0);
        
    }
}
