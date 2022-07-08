import peasy.*;
PeasyCam cam;

Snake mySnake;

void setup() {
  size(1280, 720, P3D);
  mySnake = new Snake(1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1);
  //mySnake = new Snake(1, 1, 1, 1, 0, 0);
  CubeMatrixGroup my_matg = gen_cube_group();
  my_matg.print();
  
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(3000);
}

void draw() {
  background(0);
  randomSeed(keko);
  directionalLight(51, 102, 126, -0.5, 1.0, 0.3);
  directionalLight(255, 230, 200, 0.6, -1.0, -0.14);
  ambientLight(55, 55, 55);
  mySnake.draw_3D(30, -1);
  noFill();
  //stroke(100);box(width);
}

int keko;
void keyPressed() {
  keko++;
}

class Snake {
  int[] lengths;
  boolean[][][] collision_arr;
  int collision_arr_rad;
  int collision_index = 0;
  CubeMatrixGroup matg;
  Snake(int... lengths) {
    this.lengths = lengths;
    int rad = 0;
    for(int i = 0; i < lengths.length; i++) collision_arr_rad += lengths[i]+1;
    collision_arr = new boolean[collision_arr_rad*2 + 1][collision_arr_rad*2 + 1][collision_arr_rad*2 + 1];
    matg = gen_cube_group();
  }
  
  iVec3[] build_3D_structure(int[] config) {
    int current_orientation = matg.identity;
    int[] choices = matg.yz_right_rots_special.clone();
    iVec3 pos = new iVec3(0, 0, 0);
    ArrayList<iVec3> cube_positions = new ArrayList<iVec3>();
    for(int i = 0; i < lengths.length; i++) {
      for(int j = 0; j < lengths[i]+(i==lengths.length-1?2:1); j++) {
        cube_positions.add(pos.clone());
        pos.add(matg.get_x_vec(current_orientation));
      }
      if(i != lengths.length-1) {
        current_orientation = choices[config[i]];
        for(int j = 0; j < choices.length; j++) {
          choices[j] = matg.prod(current_orientation, matg.yz_right_rots_special[j]);
        }
      }
    }
    return cube_positions.toArray(new iVec3[0]);
  }
  
  boolean[] find_intersections(iVec3[] structure) {
    boolean[] out = new boolean[structure.length];
    for(int i = 0; i < structure.length; i++) {
      out[i] = collision_arr[collision_arr_rad+structure[i].x]
                            [collision_arr_rad+structure[i].y]
                            [collision_arr_rad+structure[i].z];
      collision_arr[collision_arr_rad+structure[i].x]
                   [collision_arr_rad+structure[i].y]
                   [collision_arr_rad+structure[i].z] = true;
    }
    for(int i = 0; i < structure.length; i++) {
      collision_arr[collision_arr_rad+structure[i].x]
                   [collision_arr_rad+structure[i].y]
                   [collision_arr_rad+structure[i].z] = false;
    }
    return out;
  }
  
  boolean has_intersection(iVec3[] structure) {
    int i = 0;
    boolean found = false;
    for(i = 0; i < structure.length; i++) {
      if(collision_arr[collision_arr_rad+structure[i].x]
                      [collision_arr_rad+structure[i].y]
                      [collision_arr_rad+structure[i].z]) {
        found = true;
        break;
      }
    }
    i--;
    for(; i >= 0; i--) {
      collision_arr[collision_arr_rad+structure[i].x]
                   [collision_arr_rad+structure[i].y]
                   [collision_arr_rad+structure[i].z] = false;
    }
    return found;
  }
  
  void draw_3D(float r, int segments) {
    int[] config = new int[lengths.length - 1];
    for(int i = 0; i < config.length; i++) {
      config[i] = (i%2)*2;
      config[i] = (int)random(0, 4);
    }
    iVec3[] vv = build_3D_structure(config);
    int segs = segments<0?vv.length:segments;
    boolean[] red = find_intersections(vv);
    for(int i = 0; i < segs; i++) {
      pushMatrix();
      PVector p = new PVector(vv[i].x, vv[i].y, vv[i].z);
      if(i%2==0) fill(150, 103, 53); else fill(245, 221, 176);
      if(red[i]) fill(255, 20, 20);
      p.mult(r);
      translate(p.x, p.y, p.z);
      noStroke();
      box(r*(red[i]?1.1:1.0));
      popMatrix();
    }
    hint(DISABLE_DEPTH_TEST);
    strokeWeight(2);
    beginShape();
    noFill();
    stroke(100, 255, 70);
    for(int i = 0; i < segs; i++) {
      PVector p = new PVector(vv[i].x, vv[i].y, vv[i].z);
      p.mult(r);
      vertex(p.x, p.y, p.z);
    }
    endShape();
    noStroke();
    noLights();
    fill(255, 20, 20);
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
  
  void draw_3D_debug(float r) {
    int[] orientations = new int[lengths.length - 1];
    for(int i = 0; i < orientations.length; i++) {
      orientations[i] = (i%2);
    }
    
    int current_orientation = matg.identity;
    iVec3 pos = new iVec3(0, 0, 0);
    boolean col = false;
    int[] choices = matg.yz_right_rots_special.clone();
    int[] old_choices = matg.yz_right_rots_special.clone();
    /*
    for(int i = 0; i < choices.length; i++) {
      choices[i] = matg.prod(keko%24, choices[i]);
    }
    current_orientation = matg.prod(keko%24, current_orientation);
    */
    //orientations[4] = keko%old_choices.length;
    for(int i = 0; i < lengths.length; i++) {
      stroke(0);
      for(int j = 0; j < lengths[i]+(i==lengths.length-1?2:1); j++) {
        //----------DRAW----------//
        if(col) fill(230, 195, 154); else fill(88, 138, 113);
        col = !col;
        translate(pos.x*r, pos.y*r, pos.z*r);
        box(r*0.6, r*0.6, r*0.6);
        translate(-pos.x*r, -pos.y*r, -pos.z*r);
        //----------DRAW----------//
        
        pos.add(matg.get_x_vec(current_orientation)); // advance position
      }
      noFill();
      if(i != lengths.length-1) {
        
        stroke(255);
        for(int j = 0; j < choices.length; j++) {
          int hypo_id = choices[j];
          iVec3 hypo_vec = matg.get_x_vec(hypo_id);
          
          //----------DRAW----------//
          PVector hypo_pvec = new PVector(hypo_vec.x*0.85 + pos.x, hypo_vec.y*0.85 + pos.y, hypo_vec.z*0.85 + pos.z);
          switch(j) {
            case 0: stroke(255, 0, 0); break;
            case 1: stroke(255, 255, 0); break;
            case 2: stroke(0, 255, 0); break;
            case 3: stroke(0, 255, 255); break;
            case 4: stroke(0, 0, 255); break;
            case 5: stroke(255, 0, 255); break;
            default: stroke(255); break;
          }
          if(j == orientations[i]) strokeWeight(5); else strokeWeight(1);
          line(pos.x*r, pos.y*r, pos.z*r, hypo_pvec.x*r, hypo_pvec.y*r, hypo_pvec.z*r);
          //----------DRAW----------//
        }
        strokeWeight(1);
        noStroke();
        
        
        iVec3 hypo_v = matg.get_x_vec(current_orientation);
        PVector hypo_pvec = new PVector(hypo_v.x*0.85 + pos.x, hypo_v.y*0.85 + pos.y, hypo_v.z*0.85 + pos.z);
        translate(hypo_pvec.x*r, hypo_pvec.y*r, hypo_pvec.z*r);
        fill(255);
        sphere(10);
        translate(-hypo_pvec.x*r, -hypo_pvec.y*r, -hypo_pvec.z*r);
        noFill();
        
        current_orientation = choices[orientations[i]];
        
        hypo_v = matg.get_x_vec(current_orientation);
        hypo_pvec = new PVector(hypo_v.x*0.85 + pos.x, hypo_v.y*0.85 + pos.y, hypo_v.z*0.85 + pos.z);
        translate(hypo_pvec.x*r, hypo_pvec.y*r, hypo_pvec.z*r);
        fill(255, 0, 255);
        sphere(10);
        translate(-hypo_pvec.x*r, -hypo_pvec.y*r, -hypo_pvec.z*r);
        noFill();
        
        //old_choices = choices.clone();
        for(int j = 0; j < choices.length; j++) {
          //print(old_choices[j] + " ");
          choices[j] = matg.prod(current_orientation, old_choices[j]);
          //print(choices[j] + "\n");
        }
        
      }
    }
  }
  void draw_flat(float r) {
    float x = width/2;
    float y = height/2;
    int dir = 0;
    rectMode(CENTER);
    boolean col = false;
    for(int i = 0; i < lengths.length; i++) {
      for(int j = 0; j < lengths[i]+(i==lengths.length-1?2:1); j++) {
        if(col) fill(230, 195, 154); else fill(88, 138, 113);
        col = !col;
        rect(x, y, r, r);
        switch(dir) {
          case 0:
          x+=r; break;
          case 1:
          y+=r; break;
          case 2:
          x-=r; break;
          case 3:
          y-=r; break;
          default: break;
        }
      }
      if(i%2==0) dir++; else dir--;
      dir = (dir+4)%4;
    }
  }
}
