import java.util.HashSet;
import java.util.Set;
import java.util.List;
import java.util.Arrays;

/**
 * A representation of a finite group made with 3x3 integer matrix generators.
 */
class MatrixGroup {
  iMat3[] m;
  int[][] table;
  /**
   * @param m_vals    the matrices in the group
   * @param table_val the cayley table of the group
   */
  MatrixGroup(iMat3[] m_vals, int[][] table_val) {
    m = m_vals;
    table = table_val;
  }
  /**
   * Matrix multiplication of m[a] and m[b]
   * @return   the result of a*b where * is the group composition operator
   * @param  a the left-multiplying element
   * @param  b the right-multiplying element
   */
  int prod(int a, int b) {
    return table[a][b];
  }
  /**
   * Finds result of multiplying element's matrix with <1, 0, 0>
   * @return   m[i]*<1, 0, 0> (as an iVec3)
   * @param  i the element to get the vector of
   */
  iVec3 get_x_vec(int i) {
    return new iVec3(m[i].a[0][0], m[i].a[1][0], m[i].a[2][0]);
  }
  
  /**
   * Prints matrices and cayley table
   */
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

/**
 * The chiral octahedral symmetry group
 */
class CubeMatrixGroup extends MatrixGroup {
  String[] tags; // "tags" that mark the meanings of different elements
  
  int[] x_rots; // indices of rotations around x-axis
  int[] y_rots; // indices of rotations around y-axis
  int[] z_rots; // indices of rotations around z-axis
  int[] right_rots; // indices of 90-degree rotation elements
  int[] yz_right_rots_special; // indices of snake cube joint rotation elements
  int identity; // the identity element index
  
  /**
   * @param m_vals    the matrices in the group (should have length 24)
   * @param table_val the cayley table of the group (should be 24x24)
   */
  CubeMatrixGroup(iMat3[] m_vals, int[][] table_val) {
    super(m_vals, table_val);
    tags = new String[m_vals.length];
    for(int i = 0; i < m_vals.length; i++) {
      tags[i] = "";
    }
    
    // tag which elements represent rotations around axes
    x_rots = get_invariants(new iVec3(1, 0, 0));
    for(int i : x_rots) tags[i] += "[x-invariant]";
    y_rots = get_invariants(new iVec3(0, 1, 0));
    for(int i : y_rots) tags[i] += "[y-invariant]";
    z_rots = get_invariants(new iVec3(0, 0, 1));
    for(int i : z_rots) tags[i] += "[z-invariant]";
    
    // find the identity element and 90-degree rotations and tag
    ArrayList<Integer> right_rots_list = new ArrayList<Integer>();
    for(int i = 0; i < m_vals.length; i++) {
      // x/y invariance imply z-invariance because group is chiral (no mirrors)
      if(tags[i].contains("[x-invariant][y-invariant]")) {
        identity = i;
        tags[i] += "[identity]";
      }
      if(tags[i].contains("invariant")) {
        // checks that there are 2 zeros and a single 1 on the diagonal
        if((m[i].a[0][0]+1)*(m[i].a[1][1]+1)*(m[i].a[2][2]+1) == 2) {
          tags[i] += "[90deg]";
          right_rots_list.add(i);
        }
      }
    }
    right_rots = right_rots_list.stream().mapToInt(Integer::intValue).toArray();
    
    // Find the snake puzzle rotation elements
    // Surprisingly, this is nontrivial (we can't just use 90 degree rotations along y and z axes)
    // Instead we rotate "up" along the y-axis, then rotate this element around the x axis four times.
    yz_right_rots_special = new int[4];
    yz_right_rots_special[0] = get_with_tags("y-invariant", "90deg")[0];
    int xr = get_with_tags("x-invariant", "90deg")[0];
    yz_right_rots_special[1] = prod(xr, yz_right_rots_special[0]);
    yz_right_rots_special[2] = prod(xr, yz_right_rots_special[1]);
    yz_right_rots_special[3] = prod(xr, yz_right_rots_special[2]);
  }
  /**
   * @param input the tags to search for
   * @returns     the ids of elements that have tags (input[1]&&input[2]&&...&&input[n])
   */
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
  /**
   * @param v the invariant vector
   * @returns elements that, when their matrices are multiplied with v, result in the same vector
   */
  int[] get_invariants(iVec3 v) {
    ArrayList<Integer> ids = new ArrayList<Integer>();
    for(int i = 0; i < m.length; i++) {
      if(mult(m[i], v).equals(v)) ids.add(i);
    }
    return ids.stream().mapToInt(Integer::intValue).toArray();
  }
  
  /**
   * Prints matrices, tags, and cayley table
   */
  @Override
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

/**
 * @returns the one and only chiral octahedral symmetry group
 */
CubeMatrixGroup gen_cube_group() {
  int[][] g_pm1 = {{1, 0, 0}, {0, 0, -1}, {0, 1, 0}}; // X-axis 90 degree rotation
  int[][] g_pm2 = {{0, 1, 0}, {-1, 0, 0}, {0, 0, 1}}; // z-axis 90 degree rotation
  iMat3 p1 = new iMat3(g_pm1);
  iMat3 p2 = new iMat3(g_pm2);
  MatrixGroup m = gen_from_matrices(p1, p2);
  return new CubeMatrixGroup(m.m, m.table);
}

/**
 * Makes a finite group from 3x3 integer generating matrices
 * @param generators the generating matrices of the group
 * @returns          the resulting group
 */
MatrixGroup gen_from_matrices(iMat3... generators) {
  HashSet<iMat3> elements = new HashSet<>();
  elements.add(new iMat3()); // add the identity element
  
  int psize = 0;
  while(elements.size() != psize) { // loop until the group isn't getting any larger
    psize = elements.size();
    HashSet<iMat3> toAdd = new HashSet<>();
    // multiply each existing element by each generator and add to set
    for(iMat3 e : elements) {
      for(iMat3 m : generators) {
        toAdd.add(mult(e, m));
      }
    }
    elements.addAll(toAdd);
  }
  
  // all elements are there, now we need the cayley table
  int[][] cayley = new int[elements.size()][elements.size()];
  List<iMat3> list_elems = new ArrayList<>(elements);
  for(int i = 0; i < list_elems.size(); i++) {
    for(int j = 0; j < list_elems.size(); j++) {
      // cayley[i][j] refers to the result of multiplying (element i)*(element j)
      // the order is important! matrix multiplication is non-commutative
      cayley[i][j] = list_elems.indexOf(mult(list_elems.get(i), list_elems.get(j)));
    }
  }
  
  MatrixGroup mg = new MatrixGroup(list_elems.toArray(new iMat3[0]), cayley);
  return mg;
}

// some handy functions for printing
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
