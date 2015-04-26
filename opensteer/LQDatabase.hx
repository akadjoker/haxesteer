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



/**

 * This structure represents the spatial database.  Typically one of

 * these would be created, by a call to lqCreateDatabase, for a given

 * application.

 */class LQDatabase {

    // the origin is the super-brick corner minimum coordinates
        var Origin : Vec3;
    // length of the edges of the super-brick
        var Size : Vec3;
    // number of sub-brick divisions in each direction
        var DivX : Int;
    var DivY : Int;
    var DivZ : Int;
    // pointer to an array of pointers, one for each bin
        // The last index is the extra bin for "everything else" (points outside super-brick)
        var bins : Array<ClientProxy>;
    // extra bin for "everything else" (points outside super-brick)
        //ClientProxy other;
        /**

     * Allocate and initialize an LQ database, return a pointer to it.

     * The application needs to call this before using the LQ facility.

     * The nine parameters define the properties of the "super-brick":

     * 

     * @param origin: coordinates of one corner of the super-brick, its minimum x, y and z extent.

     * @param size: the width, height and depth of the super-brick.

     * @param the number of subdivisions (sub-bricks) along each axis.

     * 

     * This routine also allocates the bin array, and initialize its

     * contents.

     */    public function new(origin : Vec3, size : Vec3, divx : Int, divy : Int, divz : Int) {
        Origin = origin;
        Size = size;
        DivX = divx;
        DivY = divy;
        DivZ = divz;
        // The last index is the "other" bin
        var bincount : Int = divx * divy * divz + 1;
        bins = new Array<ClientProxy>();
        var i : Int = 0;
        while(i < bins.length) {
            bins[i] = null;
            i++;
        }
    }

    /**

     * Determine index into linear bin array given 3D bin indices

     * @param    ix

     * @param    iy

     * @param    iz

     * @return

     */    public function BinCoordsToBinIndex(ix : Int, iy : Int, iz : Int) : Int {
        return ((ix * DivY * DivZ) + (iy * DivZ) + iz);
    }

    /**

     * Call for each client obj every time its location changes.  For

     * example, in an animation application, this would be called each

     * frame for every moving obj.

     *  

     * @param    obj

     * @param    position

     */    public function UpdateForNewLocation(obj : ClientProxy, position : Vec3) : ClientProxy {
        /* find bin for new location */var newBin : Int = BinForLocation(position);
        /* store location in client obj, for future reference */obj.Position = position;
        /* has obj moved into a new bin? */if(newBin != obj.Bin)  {
            obj = RemoveFromBin(obj);
            obj = AddToBin(obj, newBin);
        }
;
        return obj;
    }

    /**

     * Adds a given client obj to a given bin, linking it into the bin

     *  contents list.

     *  

     * @param    obj

     * @param    binIndex

     */    public function AddToBin(obj : ClientProxy, binIndex : Int) : ClientProxy {
        /* if bin is currently empty */if(bins[binIndex] == null)  {
            obj.Prev = null;
            obj.Next = null;
        }

        else  {
            obj.Prev = null;
            obj.Next = bins[binIndex];
            bins[binIndex].Prev = obj;
        }
;
        bins[binIndex] = obj;
        /* record bin ID in proxy obj */obj.Bin = binIndex;
        return obj;
    }

    /* Find the bin ID for a location in space.  The location is given in

       terms of its XYZ coordinates.  The bin ID is a pointer to a pointer

       to the bin contents list.  */    public function BinForLocation(position : Vec3) : Int {
        /* if point outside super-brick, return the "other" bin */if(position.x < Origin.x || position.y < Origin.y || position.z < Origin.z || position.x >= Origin.x + Size.x || position.y >= Origin.y + Size.y || position.z >= Origin.z + Size.z)  {
            return bins.length - 1;
        }
;
        /* if point inside super-brick, compute the bin coordinates */var ix : Int = Std.int((((position.x - Origin.x) / Size.x) * DivX));
        var iy : Int = Std.int((((position.y - Origin.y) / Size.y) * DivY));
        var iz : Int = Std.int((((position.z - Origin.z) / Size.z) * DivZ));
        /* convert to linear bin number */var i : Int = BinCoordsToBinIndex(ix, iy, iz);
        /* return pointer to that bin */return i;
    }

    /* Apply an application-specific function to all objects in a certain

       locality.  The locality is specified as a sphere with a given

       center and radius.  All objects whose location (key-point) is

       within this sphere are identified and the function is applied to

       them.  The application-supplied function takes three arguments:



     (1) a void* pointer to an lqClientProxy's "object".

     (2) the square of the distance from the center of the search

     locality sphere (x,y,z) to object's key-point.

     (3) a void* pointer to the caller-supplied "client query state"

     object -- typically NULL, but can be used to store state

     between calls to the lqCallBackFunction.



       This routine uses the LQ database to quickly reject any objects in

       bins which do not overlap with the sphere of interest.  Incremental

       calculation of index values is used to efficiently traverse the

       bins of interest. */    public function MapOverAllObjectsInLocality(center : Vec3, radius : Float, func : Dynamic, clientQueryState : Dynamic) : Void {
        var partlyOut : Int = 0;
        var completelyOutside : Bool = (((center.x + radius) < Origin.x) || ((center.y + radius) < Origin.y) || ((center.z + radius) < Origin.z) || ((center.x - radius) >= Origin.x + Size.x) || ((center.y - radius) >= Origin.y + Size.y) || ((center.z - radius) >= Origin.z + Size.z));
        var minBinX : Int;
        var minBinY : Int;
        var minBinZ : Int;
        var maxBinX : Int;
        var maxBinY : Int;
        var maxBinZ : Int;
        /* is the sphere completely outside the "super brick"? */if(completelyOutside)  {
            MapOverAllOutsideObjects(center, radius, func, clientQueryState);
            return;
        }
;
        /* compute min and max bin coordinates for each dimension */minBinX = Std.int(((((center.x - radius) - Origin.x) / Size.x) * DivX));
        minBinY = Std.int(((((center.y - radius) - Origin.y) / Size.y) * DivY));
        minBinZ = Std.int(((((center.z - radius) - Origin.z) / Size.z) * DivZ));
        maxBinX = Std.int(((((center.x + radius) - Origin.x) / Size.x) * DivX));
        maxBinY = Std.int(((((center.y + radius) - Origin.y) / Size.y) * DivY));
        maxBinZ = Std.int(((((center.z + radius) - Origin.z) / Size.z) * DivZ));
        /* clip bin coordinates */if(minBinX < 0)  {
            partlyOut = 1;
            minBinX = 0;
        }
;
        if(minBinY < 0)  {
            partlyOut = 1;
            minBinY = 0;
        }
        if(minBinZ < 0)  {
            partlyOut = 1;
            minBinZ = 0;
        }
        if(maxBinX >= DivX)  {
            partlyOut = 1;
            maxBinX = DivX - 1;
        }
        if(maxBinY >= DivY)  {
            partlyOut = 1;
            maxBinY = DivY - 1;
        }
        if(maxBinZ >= DivZ)  {
            partlyOut = 1;
            maxBinZ = DivZ - 1;
        }
        /* map function over outside objects if necessary (if clipped) */if(partlyOut != 0) 
            MapOverAllOutsideObjects(center, radius, func, clientQueryState);
        /* map function over objects in bins */MapOverAllObjectsInLocalityClipped(center, radius, func, clientQueryState, minBinX, minBinY, minBinZ, maxBinX, maxBinY, maxBinZ);
    }

    /* Given a bin's list of client proxies, traverse the list and invoke

    the given lqCallBackFunction on each obj that falls within the

    search radius.  */    public function TraverseBinClientObjectList(co : ClientProxy, radiusSquared : Float, func : Dynamic, state : Dynamic, position : Vec3) : ClientProxy {
        while(co != null) {
            // compute distance (squared) from this client obj to given
            // locality sphere's centerpoint
            var d : Vec3 = Vec3.VectorSubtraction(position, co.Position);
            var distanceSquared : Float = d.SquaredMagnitude();
            // apply function if client obj within sphere
            if (distanceSquared < radiusSquared) 
            {
               /* func.call(null, {
                clientObject : co.Obj,
                objectDistanceSquared : distanceSquared,
                objectState : state }*/
                var o:Dynamic = {
                clientObject : co.Obj, 
                objectDistanceSquared : distanceSquared,
                objectState : state };
                Reflect.callMethod(null, func, [o]);                
            }
            // consider next client obj in bin list
            co = co.Next;
        }

        return co;
    }

    /* This subroutine of lqMapOverAllObjectsInLocality efficiently

       traverses of subset of bins specified by max and min bin

       coordinates. */    public function MapOverAllObjectsInLocalityClipped(center : Vec3, radius : Float, func : Dynamic, clientQueryState : Dynamic, minBinX : Int, minBinY : Int, minBinZ : Int, maxBinX : Int, maxBinY : Int, maxBinZ : Int) : Void {
        var i : Int;
        var j : Int;
        var k : Int;
        var iindex : Int;
        var jindex : Int;
        var kindex : Int;
        var slab : Int = DivY * DivZ;
        var row : Int = DivZ;
        var istart : Int = minBinX * slab;
        var jstart : Int = minBinY * row;
        var kstart : Int = minBinZ;
        var co : ClientProxy;
        var bin : ClientProxy;
        var radiusSquared : Float = radius * radius;
        /* loop for x bins across diameter of sphere */iindex = istart;
        i = minBinX;
        while(i <= maxBinX) {
            /* loop for y bins across diameter of sphere */jindex = jstart;
            j = minBinY;
            while(j <= maxBinY) {
                /* loop for z bins across diameter of sphere */kindex = kstart;
                k = minBinZ;
                while(k <= maxBinZ) {
                    /* get current bin's client obj list */bin = bins[iindex + jindex + kindex];
                    co = bin;
                    /* traverse current bin's client obj list */co = TraverseBinClientObjectList(co, radiusSquared, func, clientQueryState, center);
                    kindex += 1;
                    k++;
                }
                jindex += row;
                j++;
            }
            iindex += slab;
            i++;
        }
    }

    /* If the query region (sphere) extends outside of the "super-brick"

       we need to check for objects in the catch-all "other" bin which

       holds any object which are not inside the regular sub-bricks  */    public function MapOverAllOutsideObjects(center : Vec3, radius : Float, func : Dynamic, clientQueryState : Dynamic) : Void {
        var co : ClientProxy = bins[bins.length - 1];
        var radiusSquared : Float = radius * radius + 0.0;
        // traverse the "other" bin's client object list
        co = TraverseBinClientObjectList(co, radiusSquared, func, clientQueryState, center);
    }

    /* public helper function */    public function MapOverAllObjectsInBin(binProxyList : ClientProxy, func : Dynamic, clientQueryState : Dynamic) : Void {
        // walk down proxy list, applying call-back function to each one
        while(binProxyList != null) {
            /*func.call(null, {
                clientObject : binProxyList.Obj,
                objectDistanceSquared : 0,
                objectState : clientQueryState,

            });*/
            
            var o:Dynamic = {
                clientObject : binProxyList.Obj,
                objectDistanceSquared : 0,
                objectState : clientQueryState,

            };
            Reflect.callMethod(null, func, [o]);
            
            binProxyList = binProxyList.Next;
        }
    }

    /* Apply a user-supplied function to all objects in the database,

       regardless of locality (cf lqMapOverAllObjectsInLocality) */    public function MapOverAllObjects(func : Dynamic, clientQueryState : Dynamic) : Void {
        var i : Int = 0;
        while(i < bins.length) {
            MapOverAllObjectsInBin(bins[i], func, clientQueryState);
            i++;
        }
    }

    /* Removes a given client obj from its current bin, unlinking it

       from the bin contents list. */    public function RemoveFromBin(obj : ClientProxy) : ClientProxy {
        /* adjust pointers if obj is currently in a bin */if(obj.Bin != 0)  {
            /* If this obj is at the head of the list, move the bin

               pointer to the next item in the list (might be null). */if(bins[obj.Bin] == obj) 
                bins[obj.Bin] = obj.Next;
            /* If there is a prev obj, link its "next" pointer to the

               obj after this one. */if(obj.Prev != null) 
                obj.Prev.Next = obj.Next;
            /* If there is a next obj, link its "prev" pointer to the

               obj before this one. */if(obj.Next != null) 
                obj.Next.Prev = obj.Prev;
        }
;
        /* Null out prev, next and bin pointers of this obj. */obj.Prev = null;
        obj.Next = null;
        obj.Bin = 0;
        return obj;
    }

    /* Removes (all proxies for) all objects from all bins */    public function RemoveAllObjects() : Void {
        var i : Int = 0;
        while(i < bins.length) {
            bins[i] = RemoveAllObjectsInBin(bins[i]);
            i++;
        }
    }

    /* public helper function */    function RemoveAllObjectsInBin(bin : ClientProxy) : ClientProxy {
        while(bin != null) {
            bin = RemoveFromBin(bin);
        }

        return bin;
    }

    static function FindNearestHelper(clientObject : Dynamic, distanceSquared : Float, clientQueryState : Dynamic) : Void {
        var fns : FindNearestState = cast(clientQueryState, FindNearestState);
        /* do nothing if this is the "ignoreObject" */if(fns.ignoreObject != clientObject)  {
            /* record this object if it is the nearest one so far */if(fns.minDistanceSquared > distanceSquared)  {
                fns.nearestObject = clientObject;
                fns.minDistanceSquared = distanceSquared;
            }
;
        }
;
    }

    /* Search the database to find the object whose key-point is nearest

       to a given location yet within a given radius.  That is, it finds

       the object (if any) within a given search sphere which is nearest

       to the sphere's center.  The ignoreObject argument can be used to

       exclude an object from consideration (or it can be NULL).  This is

       useful when looking for the nearest neighbor of an object in the

       database, since otherwise it would be its own nearest neighbor.

       The function returns a void* pointer to the nearest object, or

       NULL if none is found.  */    public function FindNearestNeighborWithinRadius(center : Vec3, radius : Float, ignoreObject : Dynamic) : Dynamic {
        /* initialize search state */var lqFNS : FindNearestState = new FindNearestState();
        lqFNS.nearestObject = null;
        lqFNS.ignoreObject = ignoreObject;
        lqFNS.minDistanceSquared = Math.POSITIVE_INFINITY;
        /* map search helper function over all objects within radius */MapOverAllObjectsInLocality(center, radius, FindNearestHelper, lqFNS);
        /* return nearest object found, if any */return lqFNS.nearestObject;
    }

}

class FindNearestState {

    public var ignoreObject : Dynamic;
    public var nearestObject : Dynamic;
    public var minDistanceSquared : Float;

    public function new() {
    }
}

