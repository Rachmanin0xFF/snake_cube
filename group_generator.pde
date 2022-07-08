import java.util.HashSet;
import java.util.Set;
import java.util.List;
import java.util.Arrays;

String to_str(int[] l) {
  String s = "";
  for(int n : l) s += (nf(n, 2) + " ");
  s = s.substring(0, s.length()-1);
  return s;
}

String[] to_str_array(int[][] dat) {
  String[] o = new String[dat.length];
  for(int i = 0; i < dat.length; i++) {
    o[i] = to_str(dat[i]);
  }
  return o;
}

class MatrixGroup {
  iMat3[] m;
  int[][] table;
  MatrixGroup(iMat3[] m_vals, int[][] table_val) {
    m = m_vals;
    table = table_val;
  }
  // Just for clairty
  int prod(int a, int b) {
    return table[a][b];
  }
  iMat3 id_to_mat(int i) {
    return m[i];
  }
  iVec3 get_x_vec(int i) {
    return new iVec3(m[i].a[0][0], m[i].a[1][0], m[i].a[2][0]);
  }
  void print() {
    for(int i = 0; i < m.length; i++) {
      println("Matrix " + i + ":");
      m[i].print_nice();
    }
    String[] table_print = to_str_array(table);
    println("Cayley Table:");
    for(String s : table_print) println(s);
  }
}

class CubeMatrixGroup extends MatrixGroup {
  String[] tags;
  int[] x_rots;
  int[] y_rots;
  int[] z_rots;
  int[] right_rots; // right angles
  int[] yz_right_rots;
  int[] yz_right_rots_special;
  int identity;
  CubeMatrixGroup(iMat3[] m_vals, int[][] table_val) {
    super(m_vals, table_val);
    tags = new String[m_vals.length];
    for(int i = 0; i < m_vals.length; i++) {
      tags[i] = "";
    }
    
    x_rots = get_invariants(new iVec3(1, 0, 0));
    for(int i : x_rots) tags[i] += "[x-invariant]";
    y_rots = get_invariants(new iVec3(0, 1, 0));
    for(int i : y_rots) tags[i] += "[y-invariant]";
    z_rots = get_invariants(new iVec3(0, 0, 1));
    for(int i : z_rots) tags[i] += "[z-invariant]";
    
    ArrayList<Integer> right_rots_list = new ArrayList<Integer>();
    for(int i = 0; i < m_vals.length; i++) {
      if(tags[i].contains("[x-invariant][y-invariant]")) {
        identity = i;
        tags[i] += "[identity]";
      }
      if(tags[i].contains("invariant")) {
        if((m[i].a[0][0]+1)*(m[i].a[1][1]+1)*(m[i].a[2][2]+1) == 2) {
          tags[i] += "[90deg]";
          right_rots_list.add(i);
        }
      }
    }
    right_rots = right_rots_list.stream().mapToInt(Integer::intValue).toArray();
    
    ArrayList<Integer> yz_right_rots_list = new ArrayList<Integer>();
    ArrayList<Integer> y_right_rots_list = new ArrayList<Integer>();
    for(int i = 0; i < m_vals.length; i++) {
      if(tags[i].contains("90deg") && !tags[i].contains("x-invariant")) {
        yz_right_rots_list.add(i);
        tags[i] += "[yz-right-rots]";
      }
      if(tags[i].contains("90deg") && tags[i].contains("y-invariant")) {
        y_right_rots_list.add(i);
        tags[i] += "[y-right-rots]";
      }
    }
    yz_right_rots = yz_right_rots_list.stream().mapToInt(Integer::intValue).toArray();
    
    yz_right_rots_special = new int[4];
    yz_right_rots_special[0] = get_with_tags("y-invariant", "90deg")[0];
    int xr = get_with_tags("x-invariant", "90deg")[0];
    yz_right_rots_special[1] = prod(xr, yz_right_rots_special[0]);
    yz_right_rots_special[2] = prod(xr, yz_right_rots_special[1]);
    yz_right_rots_special[3] = prod(xr, yz_right_rots_special[2]);
  }
  int[] get_with_tags(String... input) {
    ArrayList<Integer> lst = new ArrayList<Integer>();
    for(int i = 0; i < m.length; i++) {
      boolean has = true;
      for(int j = 0; j < input.length; j++) {
        has &= tags[i].contains(input[j]);
      }
      if(has) lst.add(i);
    }
    return lst.stream().mapToInt(Integer::intValue).toArray();
  }
  int get_specific_mat(iMat3 my_m) {
    for(int i = 0; i < m.length; i++) {
      if(my_m.equals(m[i])) return i;
    }
    return -1;
  }
  // returns matrices that, when multiplied with v, result in the same vector
  int[] get_invariants(iVec3 v) {
    ArrayList<Integer> ids = new ArrayList<Integer>();
    for(int i = 0; i < m.length; i++) {
      if(mult(m[i], v).equals(v)) ids.add(i);
    }
    return ids.stream().mapToInt(Integer::intValue).toArray();
  }
  void print() {
    for(int i = 0; i < m.length; i++) {
      println("Matrix " + i + ":");
      println("Tags: " + tags[i]);
      m[i].print_nice();
    }
    String[] table_print = to_str_array(table);
    println("Cayley Table:");
    for(String s : table_print) println(s);
  }
}

CubeMatrixGroup gen_cube_group() {
  int[][] g_pm1 = {{1, 0, 0}, {0, 0, -1}, {0, 1, 0}}; // X-axis 90 degree rotation
  int[][] g_pm2 = {{0, 1, 0}, {-1, 0, 0}, {0, 0, 1}}; // z-axis 90 degree rotation
  iMat3 p1 = new iMat3(g_pm1);
  iMat3 p2 = new iMat3(g_pm2);
  MatrixGroup m = gen_from_matrices(p1, p2);
  return new CubeMatrixGroup(m.m, m.table);
}

class VectorGroup {
  int[][] table;
  iVec3 v;
}
VectorGroup gen_ortho() {
  return null;
}

MatrixGroup gen_from_matrices(iMat3... generators) {
  HashSet<iMat3> elements = new HashSet<>();
  elements.add(new iMat3());
  
  int psize = 0;
  while(elements.size() != psize) {
    psize = elements.size();
    HashSet<iMat3> toAdd = new HashSet<>();
    for(iMat3 e : elements) {
      for(iMat3 m : generators) {
        toAdd.add(mult(e, m));
      }
    }
    elements.addAll(toAdd);
  }
  
  int[][] cayley = new int[elements.size()][elements.size()];
  List<iMat3> list_elems = new ArrayList<>(elements);
  for(int i = 0; i < list_elems.size(); i++) {
    for(int j = 0; j < list_elems.size(); j++) {
      cayley[i][j] = list_elems.indexOf(mult(list_elems.get(i), list_elems.get(j)));
    }
  }
  
  MatrixGroup mg = new MatrixGroup(list_elems.toArray(new iMat3[0]), cayley);
  return mg;
}
