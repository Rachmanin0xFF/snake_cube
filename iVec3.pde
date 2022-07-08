/**
 * A simple class to represent 3-component integer vectors
 */
class iVec3 {
  int x, y, z;
  iVec3() {
    x = 0;
    y = 0;
    z = 0;
  }
  iVec3(int s) {
    x = s;
    y = s;
    z = s;
  }
  iVec3(int x, int y, int z) {
    this.x = x; this.y = y; this.z = z;
  }
  iVec3(iVec3 v) {
    this.x = v.x; this.y = v.y; this.z = v.z;
  }
  void add(iVec3 v) {
    x += v.x; y += v.y; z += v.z;
  }
  void sub(iVec3 v) {
    x -= v.x; y -= v.y; z -= v.z;
  }
  void mult(int w) {
    x *= w; y *= w; z *= w;
  }
  PVector toPVector() {
    return new PVector((float)x, (float)y, (float)z);
  }
  int dot(iVec3 a) {
    return a.x*x + a.y*y + a.z*z;
  }
  int max_component() {
    return x > y && x > z ? x : (y > z ? y : z);
  }
  int min_component() {
    return x < y && x < z ? x : (y < z ? y : z);
  }
  @Override
  public boolean equals(Object obj) {
    return x == ((iVec3)obj).x && y ==((iVec3)obj).y && z == ((iVec3)obj).z;
  }
  // note: hashCode() and euqals() may not agree for large corrdinates (diff>=1024)
  // HashSet calls equals() though, so it shouldn't be a problem in this project
  @Override
  public int hashCode() {
    return (x<<20)+(y<<10)+z;
  }
  void print_nice() {
    println("[ " + x + ", " + y + ", " + z + " ]");
  }
  iVec3 clone() {
    return new iVec3(x, y, z);
  }
}
iVec3 add(iVec3 a, iVec3 b) {
  return new iVec3(a.x + b.x, a.y + b.y, a.z + b.z);
}
iVec3 sub(iVec3 a, iVec3 b) {
  return new iVec3(a.x - b.x, a.y - b.y, a.z - b.z);
}
iVec3 cross(iVec3 a, iVec3 b) {
  return new iVec3(a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x);
}
iVec3 min(iVec3 a, iVec3 b) {
  return new iVec3(a.x<b.x?a.x:b.x, a.y<b.y?a.y:b.y, a.z<b.z?a.z:b.z);
}
iVec3 max(iVec3 a, iVec3 b) {
  return new iVec3(a.x>b.x?a.x:b.x, a.y>b.y?a.y:b.y, a.z>b.z?a.z:b.z);
}
int dot(iVec3 a, iVec3 b) {
  return a.dot(b);
}
