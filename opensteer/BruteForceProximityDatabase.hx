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



class BruteForceProximityDatabase implements IProximityDatabase {
    public var Count(get, null) : Int;
    public var group(get, set) : Array<TokenType>;

    // Contains all tokens in database
        var _group : Array<TokenType>;
    // constructor
        public function new() 
		{
        _group = new Array<TokenType>();
    }

    // allocate a token to represent a given client object in this database
        public function AllocateToken(parentObject : Dynamic) : ITokenForProximityDatabase {
        return new TokenType(parentObject, this);
    }

    // return the number of tokens currently in the database
        public function get_Count() : Int {
        return group.length;
    }

    public function get_group() : Array<TokenType> {
        return _group;
    }

    public function set_group(value : Array<TokenType>) : Array<TokenType> 
	{
        _group = value;
        return value;
    }

}

class TokenType implements ITokenForProximityDatabase 
{

    var bfpd : BruteForceProximityDatabase;
    var obj : Dynamic;
    var position : Vec3;
    // constructor
        public function new(parentObject : Dynamic, pd : BruteForceProximityDatabase) {
        // store pointer to our associated database and the obj this
        // token represents, and store this token on the database's vector
        bfpd = pd;
        obj = parentObject;
        bfpd.group.push(this);
        position = Vec3.Zero;
    }

    // destructor
        public function Dispose() : Void {
        if(obj != null)  {
            bfpd.group.splice(Lambda.indexOf(bfpd.group,this), 1);
            obj = null;
        }
	
    //    System.gc();
	//DJOKER
	//garbage collection process.
    }

    // the client obj calls this each time its position changes
        public function UpdateForNewPosition(newPosition : Vec3) : Void {
        position = newPosition;
    }

    // find all neighbors within the given sphere (as center and radius)
        public function FindNeighbors(center : Vec3, radius : Float, results : Array<IVehicle>) : Array<IVehicle> {
        // loop over all tokens
        var r2 : Float = radius * radius;
        var i : Int = 0;
        while(i < bfpd.group.length) {
            //trace("BruteForceProximityDatabase.FindNeighbors",center,bfpd.group[i].obj);
            var offset : Vec3 = Vec3.VectorSubtraction(center, bfpd.group[i].position);
            var d2 : Float = offset.SquaredMagnitude();
            // push onto result vector when within given radius
            if(d2 < r2)  {
                results.push(bfpd.group[i].obj);
            }
;
            i++;
        }
        return results;
    }

}

