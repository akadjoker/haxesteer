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

interface IVehicle extends ILocalSpace 
 {
  public  var Mass(get, set) : Float;
  public   var Radius(get, set) : Float;
  public  var Velocity(get, null) : Vec3;
  public  var Acceleration(get, null) : Vec3;
   public var Speed(get, set) : Float;
   public var MaxForce(get, set) : Float;
   public var MaxSpeed(get, set) : Float;

    // mass (defaults to unity so acceleration=force)
  public  function get_Mass() : Float;
   public function set_Mass(mass : Float) : Float;
    // size of bounding sphere, for obstacle avoidance, etc.
  public  function get_Radius() : Float;
   public function set_Radius(radius : Float) : Float;
    // velocity of vehicle
    public    function get_Velocity() : Vec3;
    /**

     * Gets the acceleration of the vehicle

     * @return Vec3

     */    
		public function get_Acceleration() : Vec3;
    // speed of vehicle (may be faster than taking magnitude of velocity)
     public   function get_Speed() : Float;
	 public function set_Speed(speed : Float) : Float;
    // predict position of this vehicle at some time in the future
        //(assumes velocity remains constant)
      public  function PredictFuturePosition(predictionTime : Float) : Vec3;
    // ----------------------------------------------------------------------
        // XXX this vehicle-model-specific functionality seems out
        // XXX of place on the abstract base class, but for now it is expedient
        // the maximum steering force this vehicle can apply
     public   function get_MaxForce() : Float;
	 public function set_MaxForce(maxforce : Float) : Float;
    // the maximum speed this vehicle is allowed to move
     public   function get_MaxSpeed() : Float;
   public function set_MaxSpeed(maxspeed : Float) : Float;
}

