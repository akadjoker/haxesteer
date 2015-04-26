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

class Utilities {

    /**

     * 

     * @param    alpha

     * @param    x0

     * @param    x1

     * @return

     */    static public function Interpolate(alpha : Float, x0 : Float, x1 : Float) : Float {
        return x0 + ((x1 - x0) * alpha);
    }

    /**

     * 

     * @param    alpha

     * @param    x0

     * @param    x1

     * @return

     */    static public function Interpolate2(alpha : Float, x0 : Vec3, x1 : Vec3) : Vec3 {
        return Vec3.VectorAddition(x0, Vec3.ScalarMultiplication(alpha, Vec3.VectorSubtraction(x1, x0)));
    }

    /**

     * Returns a float randomly distributed between lowerBound and upperBound

     * @param    lowerBound

     * @param    upperBound

     * @return

     */    static public function random(lowerBound : Float, upperBound : Float) : Float {
        return lowerBound + (Math.random() * (upperBound - lowerBound));
    }

    /**

     * Constrain a given value (x) to be between two (ordered) bounds min and max.

     * @param    x

     * @param    min

     * @param    max

     * @return     x Returns x if it is between the bounds, otherwise returns the nearer bound.

     */    static public function Clip(x : Float, min : Float, max : Float) : Float {
        if(x < min)  {
            return min;
        }
        if(x > max)  {
            return max;
        }
        return x;
    }

    /**

     * remap a value specified relative to a pair of bounding values

     * to the corresponding value relative to another pair of bounds.

     * Inspired by (dyna:remap-interval y y0 y1 z0 z1)

     * @param    x

     * @param    in0

     * @param    in1

     * @param    out0

     * @param    out1

     * @return

     */    static public function RemapInterval(x : Float, in0 : Float, in1 : Float, out0 : Float, out1 : Float) : Float {
        // uninterpolate: what is x relative to the interval in0:in1?
        var relative : Float = ((x - in0) / (in1 - in0));
        // now interpolate between output interval based on relative x
        return Interpolate(relative, out0, out1);
    }

    /**

     * Like remapInterval but the result is clipped to remain between

     * out0 and out1

     * @param    x

     * @param    in0

     * @param    in1

     * @param    out0

     * @param    out1

     * @return

     */    static public function RemapIntervalClip(x : Float, in0 : Float, in1 : Float, out0 : Float, out1 : Float) : Float {
        // uninterpolate: what is x relative to the interval in0:in1?
        var relative : Float = ((x - in0) / (in1 - in0)) + 0.0;
        // now interpolate between output interval based on relative x
        return Interpolate(Clip(relative, 0, 1), out0, out1);
    }

    /**

     *     classify a value relative to the interval between two bounds:

     *     returns -1 when below the lower bound

     *     returns  0 when between the bounds (inside the interval)

     *     returns +1 when above the upper bound

     * @param    x

     * @param    lowerBound

     * @param    upperBound

     * @return

     */    static public function IntervalComparison(x : Float, lowerBound : Float, upperBound : Float) : Int {
        if(x < lowerBound)  {
            return -1;
        }
        if(x > upperBound)  {
            return 1;
        }
        return 0;
    }

    /**

     * 

     * @param    initial

     * @param    walkspeed

     * @param    min

     * @param    max

     * @return

     */    static public function ScalarRandomWalk(initial : Float, walkspeed : Float, min : Float, max : Float) : Float {
        var next : Float = initial + (((Math.random() * 2) - 1) * walkspeed);
        if(next < min)  {
            return min;
        }
        if(next > max)  {
            return max;
        }
        return next;
    }

    /**

     * 

     * @param    x

     * @return

     */    static public function Square(x : Float) : Float {
        return (x * x) + 0.0;
    }

    /**

     * Blends new values into an accumulator to produce a smoothed time series

     * 

     * Modifies its third argument, a reference to the float accumulator holding

     * the "smoothed time series."

     * 

     * The first argument (smoothRate) is typically made proportional to "dt" the

     * simulation time step.  If smoothRate is 0 the accumulator will not change,

     * if smoothRate is 1 the accumulator will be set to the new value with no

     * smoothing.  Useful values are "near zero".

     *

     * @example BlendIntoAccumulator (dt * 0.4, currentFPS, smoothedFPS)

     * @param    smoothRate

     * @param    newValue

     * @param    smoothedAccumulator

     * @return

     */    static public function BlendIntoAccumulator(smoothRate : Float, newValue : Float, smoothedAccumulator : Float) : Float {
        return Interpolate(Clip(smoothRate, 0, 1), smoothedAccumulator, newValue);
    }

    /**

     * 

     * @param    smoothRate

     * @param    newValue

     * @param    smoothedAccumulator

     * @return

     */    static public function BlendIntoAccumulator2(smoothRate : Float, newValue : Vec3, smoothedAccumulator : Vec3) : Vec3 {
        return Interpolate2(Clip(smoothRate, 0, 1), smoothedAccumulator, newValue);
    }


    public function new() {
    }
}

