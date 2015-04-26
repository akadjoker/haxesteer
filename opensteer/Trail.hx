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

/**

     * Provides support to visualize the recent path of a vehicle.

     */class Trail {
    public var TrailColor(get, set) : Int;
    public var TickColor(get, set) : Int;

    var currentIndex : Int;
    // Array index of most recently recorded point
        var duration : Float;
    // Duration (in seconds) of entire trail
        var sampleInterval : Float;
    // Desired interval between taking samples
        var lastSampleTime : Float;
    // Global time when lat sample was taken
        var dottedPhase : Int;
    // Dotted line: draw segment or not
        var currentPosition : Vec3;
    // Last reported position of vehicle
        var vertices : Array<Vec3>;
    // Array (ring) of recent points along trail
        var flags : Array<Int>;
    // Array (ring) of flag bits for trail points
        var trailColor : Int;
    // Color of the trail
        var tickColor : Int;
    // Color of the ticks
        /**

         * Initializes a new instance of Trail

         *

         * @param ...args

         * @param duration The amount of time the trail represents.

         * @param vertexCount The number of samples along the trails length

         */   
        public function new(duration : Float = 5, vertexCount : Int = 100) {
        this.duration = duration;
        // Set internal trail state
        this.currentIndex = 0;
        this.lastSampleTime = 0;
        this.sampleInterval = this.duration / vertexCount;
        this.dottedPhase = 1;
        // Initialize ring buffers
        this.vertices = new Array<Vec3>();
        this.flags = new Array<Int>();
      
    }

   public function get_TrailColor() : Int {
        return trailColor;
    }

    public function set_TrailColor(val : Int) : Int {
        trailColor = val;
        return val;
    }

    public function get_TickColor() : Int {
        return tickColor;
    }

    public function set_TickColor(val : Int) : Int {
        tickColor = val;
        return val;
    }

    /**

         * Records a position for the current time, called once per update.

         * @param    currentTime

         * @param    position

         */    public function Record(currentTime : Float, position : Vec3) : Void {
        var timeSinceLastTrailSample : Float = currentTime - lastSampleTime;
        if(timeSinceLastTrailSample > sampleInterval)  {
            currentIndex = (currentIndex + 1) % vertices.length;
            vertices[currentIndex] = position;
            dottedPhase = (dottedPhase + 1) % 2;
            var tick : Bool = (Math.floor(currentTime) > Math.floor(lastSampleTime));
            flags[currentIndex] = Std.int((dottedPhase | ((tick) ? 2 : 0)));
            lastSampleTime = currentTime;
        }
        currentPosition = position;
    }

    /**

         * Draws the trail as a dotted line, fading away with age.

         * @param    drawer

         */    /*public function Draw(lines:Lines3D):void

        {

            var index:int = currentIndex;

            for (var j:int = 0; j < vertices.length; j++)

            {

                // index of the next vertex (mod around ring buffer)

                var next:int = (index + 1) % vertices.length;



                // "tick mark": every second, draw a segment in a different color

                var tick:Boolean = ((flags[index] & 2) != 0 || (flags[next] & 2) != 0);

                var color:uint= tick ? tickColor : trailColor;



                // draw every other segment

                if ((flags[index] & 1) != 0)

                {

                    if (j == 0)

                    {

                        // draw segment from current position to first trail point

                        var line:Line3D = new Line3D(lines, new LineMaterial(color, 1), 2, currentPosition.ToVertex3D(), vertices[index].ToVertex3D());

                        lines.addLine(line);

                    }

                    else

                    {

                        // draw trail segments with opacity decreasing with age

                        var minO:Number = 0.5; // minimum opacity

                        var fraction:Number = Number(j) / vertices.length;

                        var opacity:Number = fraction - minO;



                        var line2:Line3D = new Line3D(lines, new LineMaterial(color, opacity), 2, vertices[index].ToVertex3D(), vertices[next].ToVertex3D());

                        lines.addLine(line2);

                    }

                }

                index = next;

            }

        }*/    /**

         * Clear trail history. Used to prevent long streaks due to teleportation.

         */    public function Clear() : Void {
        currentIndex = 0;
        lastSampleTime = 0;
        dottedPhase = 1;
        var i : Int = 0;
        while(i < vertices.length) {
            vertices[i] = Vec3.Zero;
            flags[i] = 0;
            i++;
        }
    }

}

