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

/// <summary>
/// A local coordinate system for 3d space
/// <para>
/// Provides functionality such as transforming from local space to global
/// space and vice versa.  Also regenerates a valid space from a perturbed
/// "forward vector" which is the basis of abnstract vehicle turning.
/// </para>
/// <para>
/// These are comparable to a 4x4 homogeneous transformation matrix where the
/// 3x3 (R) portion is constrained to be a pure rotation (no shear or scale).
/// The rows of the 3x3 R matrix are the basis vectors of the space.  They are
/// all constrained to be mutually perpendicular and of unit length.  The top
/// ("x") row is called "side", the middle ("y") row is called "up" and the
/// bottom ("z") row is called forward.  The translation vector is called
/// "position".  Finally the "homogeneous column" is always [0 0 0 1].
/// </para>
/// <code>
/// [ R R R  0 ]      [ Sx Sy Sz  0 ]
/// [ R R R  0 ]      [ Ux Uy Uz  0 ]
/// [ R R R  0 ]  ->  [ Fx Fy Fz  0 ]
/// [          ]      [             ]
/// [ T T T  1 ]      [ Tx Ty Tz  1 ]
/// </code>
/// </summary>
interface ILocalSpace {
   public var Side(get, set) : Vec3;
   public var Up(get, set) : Vec3;
   public var Forward(get, set) : Vec3;
   public var Position(get, set) : Vec3;
   public var IsRightHanded(get, null) : Bool;

    // transformation as three orthonormal unit basis vectors and the
        // origin of the local space.  These correspond to the "rows" of
        // a 3x4 transformation matrix with [0 0 0 1] as the final column
        /// <summary>
        /// Gets or sets the side.
        /// </summary>
    public    function get_Side() : Vec3;
   public function set_Side(val : Vec3) : Vec3;
    /// <summary>
        /// Gets or sets the up.
        /// </summary>
    public    function get_Up() : Vec3;
   public function set_Up(val : Vec3) : Vec3;
    /// <summary>
        /// Gets or sets the forward.
        /// </summary>
       public  function get_Forward() : Vec3;
    public function set_Forward(val : Vec3) : Vec3;
    /// <summary>
        /// Gets or sets the position.
        /// </summary>
     public    function get_Position() : Vec3;
   public  function set_Position(val : Vec3) : Vec3;
    /// <summary>
        /// Indicates whether the local space is right handed.
        /// </summary>
       public  function get_IsRightHanded() : Bool;
    /// <summary>
        /// Resets the transform to identity.
        /// </summary>
     public    function ResetLocalSpace() : Void;
    /// <summary>
        /// Transforms a direction in global space to its equivalent in local space.
        /// </summary>
        /// <param name="globalDirection">The global space direction to transform.</param>
        /// <returns>The global space direction transformed to local space .</returns>
      public   function LocalizeDirection(globalDirection : Vec3) : Vec3;
    /// <summary>
        /// Transforms a point in global space to its equivalent in local space.
        /// </summary>
        /// <param name="globalPosition">The global space position to transform.</param>
        /// <returns>The global space position transformed to local space.</returns>
      public   function LocalizePosition(globalPosition : Vec3) : Vec3;
    // t
        /// <summary>
        /// Transforms a direction in local space to its equivalent in global space.
        /// </summary>
        /// <param name="localDirection">The local space direction to tranform.</param>
        /// <returns>The local space direction transformed to global space</returns>
      public   function GlobalizeDirection(localDirection : Vec3) : Vec3;
    /// <summary>
        /// Transforms a point in local space to its equivalent in global space.
        /// </summary>
        /// <param name="localPosition">The local space position to tranform.</param>
        /// <returns>The local space position transformed to global space.</returns>
     public    function GlobalizePosition(localPosition : Vec3) : Vec3;
    /// <summary>
        /// Sets the "side" basis vector to normalized cross product of forward and up.
        /// </summary>
     public    function SetUnitSideFromForwardAndUp() : Void;
    /// <summary>
        /// Regenerates the orthonormal basis vectors given a new forward.
        /// </summary>
        /// <param name="newUnitForward">The new unit-length forward.</param>
      public   function RegenerateOrthonormalBasisUF(newUnitForward : Vec3) : Void;
    /// <summary>
        /// Regenerates the orthonormal basis vectors given a new forward.
        /// </summary>
        /// <param name="newForward">The new forward.</param>
     public    function RegenerateOrthonormalBasis(newForward : Vec3) : Void;
    /// <summary>
        /// Regenerates the orthonormal basis vectors given a new forward and up.
        /// </summary>
        /// <param name="newForward">The new forward.</param>
        /// <param name="newUp">The new up.</param>
      public   function RegenerateOrthonormalBasis2(newForward : Vec3, newUp : Vec3) : Void;
    /// <summary>
        /// Rotates, in the canonical direction, a vector pointing in the
        /// "forward" (+Z) direction to the "side" (+/-X) direction as implied
        /// by IsRightHanded.
        /// </summary>
        /// <param name="value">The local space vector.</param>
        /// <returns>The rotated vector.</returns>
      public   function LocalRotateForwardToSide(val : Vec3) : Vec3;
    /// <summary>
        /// Rotates, in the canonical direction, a vector pointing in the
        /// "forward" (+Z) direction to the "side" (+/-X) direction as implied
        /// by IsRightHanded.
        /// </summary>
        /// <param name="value">The global space forward.</param>
        /// <returns>The rotated vector.</returns>
      public   function GlobalRotateForwardToSide(val : Vec3) : Vec3;
}

