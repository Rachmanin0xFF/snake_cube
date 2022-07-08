/**
 * @author Adam Lastowka
 */

Snake mySnake;

import peasy.*;
PeasyCam cam;

void setup() {
  size(1280, 720, P3D);
  // these are the lengths on my snake cube puzzle
  mySnake = new Snake(1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1);
  CubeMatrixGroup my_matg = gen_cube_group();
  my_matg.print();
  
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(3000);
}

void draw() {
  background(0);
  // make things look sort of nice
  directionalLight(51, 102, 126, -0.5, 1.0, 0.3);
  directionalLight(255, 230, 200, 0.7, -1.0, -0.14);
  ambientLight(55, 55, 55);
  
  randomSeed(keko);
  mySnake.draw_3D(mySnake.gen_random_config(), 30, -1);
}

int keko;
void keyPressed() {
  keko++;
}

/**
 * Represents the snake cube puzzle!
 */
class Snake {
  int[] lengths;
  CubeMatrixGroup matg;
  Snake(int... lengths) {
    this.lengths = lengths;
    matg = gen_cube_group();
  }
  
  /**
   * Converts configuration into 3D coordinates
   * @param config an array of numbers in range (0, 3) representing which rotation each segment is at
   * @returns      the positions each block, in order
   */
  iVec3[] build_3D_structure(int[] config) {
    int current_orientation = matg.identity; // which way we are "facing"
                                             // orientation starts as identity, direction starts as +x
    int[] choices = matg.yz_right_rots_special.clone(); // which orientations we can switch to next
    
    iVec3 pos = new iVec3(0, 0, 0); // our current position
    ArrayList<iVec3> cube_positions = new ArrayList<iVec3>(); // the cube positions!
    
    for(int i = 0; i < lengths.length; i++) {
      // add more blocks and move forwards
      for(int j = 0; j < lengths[i]+(i==lengths.length-1?2:1); j++) { // throw on an extra block if at the end
        cube_positions.add(pos.clone());
        pos.add(matg.get_x_vec(current_orientation)); // movement happens here
      }
      
      if(i != lengths.length-1) {
        current_orientation = choices[config[i]]; // pick the next choice based on config
        
        // update choices by transforming the old ones
        for(int j = 0; j < choices.length; j++) {
          choices[j] = matg.prod(current_orientation, matg.yz_right_rots_special[j]);
        }
      }
    }
    return cube_positions.toArray(new iVec3[0]);
  }
  
  /**
   * Finds intersecting vertices in a structure
   * @param structure the integer vertices of the cube
   * @returns         a boolean array designating whether each vertex is self-intersecting
   *                  note: if vertices [n] and [n+5] intersect, only the [n+5] (greater)
   *                  boolean will be true!
   */
  boolean[] find_intersections(iVec3[] structure) {
    boolean[] out = new boolean[structure.length];
    HashSet<iVec3> points = new HashSet<iVec3>();
    int psize = 0;
    int csize = 0;
    for(int i = 0; i < structure.length; i++) {
      points.add(structure[i]);
      csize = points.size();
      if(psize == csize) out[i] = true;
      psize = csize;
    }
    return out;
  }
  
  /**
   * Figures out whether the structure is physically possible or not
   * @param structure the integer vertices of the cube
   * @returns         true if the structure has a self-intersection anywhere
   */
  boolean has_intersection(iVec3[] structure) {
    HashSet<iVec3> points = new HashSet<iVec3>();
    int psize = 0;
    int csize = 0;
    for(iVec3 v : structure) {
      points.add(v);
      csize = points.size();
      if(psize == csize) return true;
      psize = csize;
    }
    return false;
  }
  
  /**
   * @returns a random configuration of the snake (may be invalid!)
   */
  int[] gen_random_config() {
    int[] config = new int[lengths.length - 1];
    for(int i = 0; i < config.length; i++) {
      config[i] = (i%2)*2;
      config[i] = (int)random(0, 4);
    }
    return config;
  }
  
  /**
   * Draws the snake in 3D given a configuration
   * @param config   the snake configuration (all elements 0-4)
   * @param r        the cube size
   * @param segments the number of segments to draw (-1 to draw all segments)
   */
  void draw_3D(int[] config, float r, int segments) {
    iVec3[] vv = build_3D_structure(config); // get coords
    boolean[] red = find_intersections(vv); // get all intersections
    
    int segs = segments<0?vv.length:min(segments, vv.length);
    
    // draw boxes first
    for(int i = 0; i < segs; i++) {
      pushMatrix();
      PVector p = new PVector(vv[i].x, vv[i].y, vv[i].z);
      // approximate colors of my snake cube at home
      if(i%2==0) fill(150, 103, 53); else fill(245, 221, 176);
      if(red[i]) fill(255, 20, 20);
      p.mult(r);
      translate(p.x, p.y, p.z);
      noStroke();
      box(r*(red[i]?1.1:1.0));
      popMatrix();
    }
    
    // draw lines over boxes
    hint(DISABLE_DEPTH_TEST);
    strokeWeight(2);
    beginShape();
    noFill(); stroke(100, 255, 70, 100);
    for(int i = 0; i < segs; i++) {
      PVector p = new PVector(vv[i].x, vv[i].y, vv[i].z);
      p.mult(r);
      vertex(p.x, p.y, p.z);
    }
    endShape();
    
    // draw spheres to mark intersections
    noStroke(); noLights();
    fill(255, 20, 20, 100);
    for(int i = 0; i < segs; i++) {
      if(red[i]) {
        PVector p = new PVector(vv[i].x, vv[i].y, vv[i].z);
        p.mult(r);
        pushMatrix(); translate(p.x, p.y, p.z);
        sphere(r*0.2);
        popMatrix();
      }
    }
    hint(ENABLE_DEPTH_TEST);
  }
}
