/**
 * @author Adam Lastowka
 */

Snake mySnake;

import peasy.*;
import java.util.stream.Collectors;
import java.util.Iterator;
PeasyCam cam;

void setup() {
  size(1280, 720, P3D);
  
  // lengths from https://www.jaapsch.net/puzzles/snakecube.htm
  
  mySnake = new Snake(1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0); // cubra red
  //mySnake = new Snake(1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0); // Kev's Kubes v9B
  //mySnake = new Snake(1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1); // these are the lengths on my snake cube puzzle
  //mySnake = new Snake(1, 0, 1, 0, 0, 2, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 2, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0); // 4^3
  CubeMatrixGroup my_matg = gen_cube_group();
  my_matg.print();
  mySnake.saved_configs = mySnake.get_configs_inside(3, 3, 3);
  
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
  random(2);
  if(mySnake.saved_configs.size() > 0)
    mySnake.draw_saved_config(keko%mySnake.saved_configs.size());
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
  ArrayList<ArrayList<Integer>> saved_configs;
  Snake(int... lengths) {
    this.lengths = lengths;
    matg = gen_cube_group();
  }
  
  /**
   * Converts configuration into 3D coordinates
   * @param config an array of numbers in range (0, 3) representing which rotation each segment is at
   * @returns      the positions each block, in order
   */
  iVec3[] build_3D_structure_list(List<Integer> config, int segments) {
    int segs = segments<0?config.size()+1:segments;
    int current_orientation = matg.identity; // which way we are "facing"
                                             // orientation starts as identity, direction starts as +x
    int[] choices = matg.yz_right_rots_special.clone(); // which orientations we can switch to next
    
    iVec3 pos = new iVec3(0, 0, 0); // our current position
    ArrayList<iVec3> cube_positions = new ArrayList<iVec3>(); // the cube positions!
    
    for(int i = 0; i < segs; i++) {
      // add more blocks and move forwards
      for(int j = 0; j < lengths[i]+(i==segs-1?2:1); j++) { // throw on an extra block if at the end
        cube_positions.add(pos.clone());
        pos.add(matg.get_x_vec(current_orientation)); // movement happens here
      }
      
      if(i != segs-1) {
        current_orientation = choices[config.get(i)]; // pick the next choice based on config
        
        // update choices by transforming the old ones
        for(int j = 0; j < choices.length; j++) {
          choices[j] = matg.prod(current_orientation, matg.yz_right_rots_special[j]);
        }
      }
    }
    return cube_positions.toArray(new iVec3[0]);
  }
  
  iVec3[] build_3D_structure(int[] config, int segments) {
    return this.build_3D_structure_list(Arrays.stream(config).boxed().collect(Collectors.toList()), segments);
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
   * @param structure the integer vertices of the snake
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
   * Determines if the given structure can fit in a box of given dimensions
   * @param structure the integer vertices of the snake
   * @param xrange    the the x-dimension of the box to fit in
   * @param yrange    the the y-dimension of the box to fit in
   * @param zrange    the the z-dimension of the box to fit in
   */
  boolean fits_inside(iVec3[] structure, int xrange, int yrange, int zrange) {
    iVec3 minv = new iVec3(0, 0, 0);
    iVec3 maxv = new iVec3(0, 0, 0);
    for(iVec3 v : structure) {
      minv = min(v, minv);
      maxv = max(v, maxv);
    }
    maxv.sub(minv);
    return maxv.x < xrange && maxv.y < yrange && maxv.z < zrange;
  }
  
  /**
   * Finds the valid configurations that do not exceed the given dimensions
   * Note: does not remove duplicates (rotations, reflections, etc.)
   * @param xrange    the the x-dimension of the box to fit in
   * @param yrange    the the y-dimension of the box to fit in
   * @param zrange    the the z-dimension of the box to fit in
   * @returns         a list of configurations (represented as ArrayList<Integer>s)
   */
  ArrayList<ArrayList<Integer>> get_configs_inside(int xrange, int yrange, int zrange) {
    HashSet<ArrayList<Integer>> possible_configs = new HashSet<ArrayList<Integer>>();
    ArrayList<Integer> a = new ArrayList<Integer>();
    //a.add(0); // fixes first config element; removes some reflections/rotations
    possible_configs.add(a); // add the starting config
    
    // we slowly grow the snake from the empty starting config
    for(int j = 0; j < lengths.length-1; j++) {
      HashSet<ArrayList<Integer>> to_add = new HashSet<ArrayList<Integer>>();
      // safe iteration setup
      for (Iterator<ArrayList<Integer>> i = possible_configs.iterator(); i.hasNext();) {
        ArrayList<Integer> e = i.next();
        
        iVec3[] vv = build_3D_structure_list(e, -1);
        if(!fits_inside(vv, xrange, yrange, zrange) || has_intersection(vv)) {
          i.remove(); // remove invalid structures from the set
        } else {
          // extend valid structures with all 4 possible directions
          ArrayList<Integer> l1 = new ArrayList<>(e); l1.add(1);
          ArrayList<Integer> l2 = new ArrayList<>(e); l2.add(2);
          ArrayList<Integer> l3 = new ArrayList<>(e); l3.add(3);
          to_add.add(l1);
          to_add.add(l2);
          to_add.add(l3);
          e.add(0); // just lengthen the current config for the 4th
        }
      }
      possible_configs.addAll(to_add);
      println("Iteration " + j + "/" + (lengths.length-2) + ": " + possible_configs.size() + " possible configurations");
    }
    
    for (Iterator<ArrayList<Integer>> i = possible_configs.iterator(); i.hasNext();) {
      ArrayList<Integer> e = i.next();
      iVec3[] vv = build_3D_structure_list(e, -1);
      if(!fits_inside(vv, xrange, yrange, zrange) || has_intersection(vv)) {
        i.remove();
      }
    }
    println("Complete: " + possible_configs.size() + " possible configurations");
    
    ArrayList<ArrayList<Integer>> cfg_list = new ArrayList<>(possible_configs);
    return cfg_list;
  }
  
  /**
   * @returns a random configuration of the snake (may be invalid!)
   */
  int[] gen_random_config() {
    int[] config = new int[lengths.length - 1];
    for(int i = 0; i < config.length; i++) {
      config[i] = (int)random(0, 4);
    }
    return config;
  }
  
  void draw_saved_config(int cfgid) {
    draw_3D(saved_configs.get(cfgid).stream().mapToInt(Integer::intValue).toArray(), 20, -1);
  }
  
  /**
   * Draws the snake in 3D given a configuration
   * @param config   the snake configuration (all elements 0-4)
   * @param r        the cube size
   * @param segments the number of segments to draw (-1 to draw all segments)
   */
  void draw_3D(int[] config, float r, int segments) {
    iVec3[] vv = build_3D_structure(config, segments); // get coords
    boolean[] red = find_intersections(vv); // get all intersections
    
    int segs = vv.length;
    
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
    noFill(); stroke(100, 255, 70, 200);
    for(int i = 0; i < segs; i++) {
      PVector p = new PVector(vv[i].x, vv[i].y, vv[i].z);
      p.mult(r);
      vertex(p.x, p.y, p.z);
    }
    endShape();
    
    // draw spheres to mark intersections
    noStroke(); noLights();
    fill(255, 20, 20, 200);
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
