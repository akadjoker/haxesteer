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

class Clock {
    public var Usage(get, null) : Float;
    public var FixedFrameRate(get, set) : Int;
    public var AnimationMode(get, set) : Bool;
    public var VariableFrameRateMode(get, set) : Bool;
    public var PausedState(get, set) : Bool;
    public var SmoothedFPS(get, null) : Float;
    public var SmoothedUsage(get, null) : Float;
    public var SmoothingRate(get, null) : Float;
    public var TotalRealTime(get, null) : Float;
    public var TotalSimulationTime(get, null) : Float;
    public var TotalPausedTime(get, null) : Float;
    public var TotalAdvanceTime(get, null) : Float;
    public var ElapsedSimulationTime(get, null) : Float;
    public var ElapsedRealTime(get, null) : Float;
    public var ElapsedNonWaitRealTime(get, null) : Float;

    // run as fast as possible, simulation time is based on real time
        var variableFrameRateMode : Bool;
    // fixed frame rate (ignored when in variable frame rate mode) in
        // real-time mode this is a "target", in animation mode it is absolute
        var fixedFrameRate : Int;
    // used for offline, non-real-time applications
        var animationMode : Bool;
    // is simulation running or paused?
        var paused : Bool;
    // clock keeps track of "smoothed" running average of recent frame rates.
        // When a fixed frame rate is used, a running average of "CPU load" is
        // kept (aka "non-wait time", the percentage of each frame time (time
        // step) that the CPU is busy).
        var smoothedFPS : Float;
    var smoothedUsage : Float;
    // clock state member variables and public accessors for them
        // real "wall clock" time since launch
        var totalRealTime : Float;
    // total time simulation has run
        var totalSimulationTime : Float;
    // total time spent paused
        var totalPausedTime : Float;
    // sum of (non-realtime driven) advances to simulation time
        var totalAdvanceTime : Float;
    // interval since last simulation time
        // (xxx does this need to be stored in the instance? xxx)
        var elapsedSimulationTime : Float;
    // interval since last clock update time
        // (xxx does this need to be stored in the instance? xxx)
        var elapsedRealTime : Float;
    // interval since last clock update,
        // exclusive of time spent waiting for frame boundary when targetFPS>0
        var elapsedNonWaitRealTime : Float;
    // "manually" advance clock by this amount on next update
        var newAdvanceTime : Float;
    var instance : Float;
    // constructor
        public function new() 
		{
        // calendar time when this clock was first started
        instance = Math.round(haxe.Timer.stamp() / 1000);
        // default is "real time, variable frame rate" and not paused
        FixedFrameRate = 0;
        PausedState = false;
        AnimationMode = false;
        VariableFrameRateMode = true;
        // real "wall clock" time since launch
        totalRealTime = 0.0;
        // time simulation has run
        totalSimulationTime = 0.0;
        // time spent paused
        totalPausedTime = 0.0;
        // sum of (non-realtime driven) advances to simulation time
        totalAdvanceTime = 0.0;
        // interval since last simulation time
        elapsedSimulationTime = 0.0;
        // interval since last clock update time
        elapsedRealTime = 0.0;
        // interval since last clock update,
        // exclusive of time spent waiting for frame boundary when targetFPS>0
        elapsedNonWaitRealTime = 0.0;
        // "manually" advance clock by this amount on next update
        newAdvanceTime = 0.0;
        // clock keeps track of "smoothed" running average of recent frame rates.
        // When a fixed frame rate is used, a running average of "CPU load" is
        // kept (aka "non-wait time", the percentage of each frame time (time
        // step) that the CPU is busy).
        smoothedFPS = 0.0;
        smoothedUsage = 0.0;
    }

    // update this clock, called exactly once per simulation step ("frame")
        public function Update() : Void 
		{
        //instance = (getTimer() - instance);
        // keep track of average frame rate and average usage percentage
        UpdateSmoothedRegisters();
        // wait for next frame time (when targetFPS>0)
        // XXX should this be at the end of the update function?
        FrameRateSync();
        // save previous real time to measure elapsed time
        var previousRealTime : Float = totalRealTime;
        // real "wall clock" time since this application was launched
        totalRealTime = RealTimeSinceFirstClockUpdate();
        // time since last clock update
        elapsedRealTime = (totalRealTime - previousRealTime);
        // accumulate paused time
        if(paused)  {
            totalPausedTime += elapsedRealTime;
        }
;
        // save previous simulation time to measure elapsed time
        var previousSimulationTime : Float = totalSimulationTime;
        // update total simulation time
        if(AnimationMode)  {
            // for "animation mode" use fixed frame time, ignore real time
            var frameDuration : Float = 1.0 / FixedFrameRate;
            totalSimulationTime += (paused) ? newAdvanceTime : frameDuration;
            if(!paused)  {
                newAdvanceTime += (frameDuration - elapsedRealTime);
            }
        }

        else  {
            // new simulation time is total run time minus time spent paused
            totalSimulationTime = (totalRealTime + totalAdvanceTime - totalPausedTime);
        }
;
        // update total "manual advance" time
        totalAdvanceTime += newAdvanceTime;
        // how much time has elapsed since the last simulation step?
        if(paused)  {
            elapsedSimulationTime = newAdvanceTime;
        }

        else  {
            elapsedSimulationTime = (totalSimulationTime - previousSimulationTime);
        }
;
        // reset advance amount
        newAdvanceTime = 0.0;
    }

    // returns the number of seconds of real time (represented as a float)
        // since the clock was first updated.
        public function RealTimeSinceFirstClockUpdate() : Float {
        if(instance == 0)  {
            instance = Math.round(haxe.Timer.stamp() / 1000) / 1000;
        }
        return (Math.round(haxe.Timer.stamp() / 1000) - instance) / 1000;
    }

    // force simulation time ahead, ignoring passage of real time.
        // Used for OpenSteerDemo's "single step forward" and animation mode
        function AdvanceSimulationTimeOneFrame() : Float {
        // decide on what frame time is (use fixed rate, average for variable rate)
        var fps : Float = ((VariableFrameRateMode) ? SmoothedFPS : FixedFrameRate);
        var frameTime : Float = 1.0 / fps;
        // bump advance time
        AdvanceSimulationTime(frameTime);
        // return the time value used (for OpenSteerDemo)
        return frameTime;
    }

    function AdvanceSimulationTime(seconds : Float) : Void {
        if(seconds < 0) 
            trace("Negative argument to advanceSimulationTime." + " seconds")
        else newAdvanceTime += seconds;
    }

    // "wait" until next frame time
        function FrameRateSync() : Void {
        // when in real time fixed frame rate mode
        // (not animation mode and not variable frame rate mode)
        if((!AnimationMode) && (!VariableFrameRateMode))  {
            // find next (real time) frame start time
            var targetStepSize : Float = 1.0 / FixedFrameRate;
            var now : Float = RealTimeSinceFirstClockUpdate();
            var lastFrameCount : Int = Std.int((now / targetStepSize));
            var nextFrameTime : Float = (lastFrameCount + 1.0) * targetStepSize;
            // record usage ("busy time", "non-wait time") for OpenSteerDemo app
            elapsedNonWaitRealTime = now - totalRealTime;
            //FIXME: eek.
            // wait until next frame time
            do{ }while((RealTimeSinceFirstClockUpdate() < nextFrameTime));
        }
;
    }

    function UpdateSmoothedRegisters() : Void 
	{
        var rate : Float = SmoothingRate;
        if(elapsedRealTime > 0)  {
            smoothedFPS = Utilities.BlendIntoAccumulator(rate, (1 / elapsedRealTime), smoothedFPS);
        }
        if(!VariableFrameRateMode)  {
            smoothedUsage = Utilities.BlendIntoAccumulator(rate, Usage, smoothedUsage);
        }
    }

    public function TogglePausedState() : Bool {
        return (paused = !paused);
    }

    // run time per frame over target frame time (as a percentage)
        public function get_Usage() : Float {
        return ((60 * elapsedNonWaitRealTime) / (1.0 / fixedFrameRate));
    }

    public function get_FixedFrameRate() : Int {
        return fixedFrameRate;
    }

    public function set_FixedFrameRate(val : Int) : Int {
        fixedFrameRate = val;
        return val;
    }

    public function get_AnimationMode() : Bool {
        return animationMode;
    }

    public function set_AnimationMode(val : Bool) : Bool {
        animationMode = val;
        return val;
    }

    public function get_VariableFrameRateMode() : Bool {
        return variableFrameRateMode;
    }

    public function set_VariableFrameRateMode(val : Bool) : Bool {
        variableFrameRateMode = val;
        return val;
    }

    public function get_PausedState() : Bool {
        return paused;
    }

    public function set_PausedState(val : Bool) : Bool {
        paused = val;
        return val;
    }

    public function get_SmoothedFPS() : Float {
        return smoothedFPS;
    }

    public function get_SmoothedUsage() : Float {
        return smoothedUsage;
    }

    public function get_SmoothingRate() : Float {
        return smoothedFPS == (0.0) ? 1.0 : elapsedRealTime * 1.5;
    }

    public function get_TotalRealTime() : Float {
        return totalRealTime;
    }

    public function get_TotalSimulationTime() : Float {
        return totalSimulationTime;
    }

    public function get_TotalPausedTime() : Float {
        return totalPausedTime;
    }

    public function get_TotalAdvanceTime() : Float {
        return totalAdvanceTime;
    }

    public function get_ElapsedSimulationTime() : Float {
        return elapsedSimulationTime;
    }

    public function get_ElapsedRealTime() : Float {
        return elapsedRealTime;
    }

    public function get_ElapsedNonWaitRealTime() : Float {
        return elapsedNonWaitRealTime;
    }

}

